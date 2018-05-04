#!/bin/bash
set -euo pipefail

this_name="dcutil"
this_title="$(echo "${this_name}" | tr '[:lower:]' '[:upper:]')"
man_dir=/usr/local/share/man
remote_repo_url="https://github.com/faiyaz7283/${this_name}.git"
if [ "$(command -v ${this_name})" ]; then
    set_script="$(dcutil --var ${this_name}_script)"
    script_dir="$(basename ${set_script})"
    set_libs_dir="$(dcutil --var ${this_name}_libs)"
    set_install_dir="$(dcutil --var ${this_name}_root)"
    exist="true"
fi

if [ -z "${exist:-}" ]; then
    if (( "$#" < 1 )); then
        echo "Not enough arguments."
        exit 1
    else
        # Arg 1: Script installation directory
        if [ -d "$1" ]; then
            script_dir="${1%/}"
            set_script="${script_dir}/${this_name}"
        else
            echo "Argument 1 must be a valid directory."
            exit 1
        fi

        # Arg 2: Libs directory
        if [ "${2:-}" ]; then
            if [ -d "$2" -a -f "${2:-}/.env" -a -d "${2:-}/docker-compose" ]; then
                set_libs_dir="${2%/}"
            else
                echo "Argument 2 must be a valid directory."
                exit 1
            fi
        else
            set_libs_dir=""
        fi

        # Arg 3: Repo directory. (Defaults to script directory)
        if [ "${3:-}" ]; then
            if [ -d "$3" ]; then
                set_install_dir="${3%/}"
            else
                echo "Argument 3 must be a valid directory."
                exit 1
            fi
        else
            set_install_dir="${script_dir}"
        fi
    fi

    if [ "$set_install_dir" == "$script_dir" ] || [[ "$set_install_dir" = *"bin"* ]]; then
        set_install_dir="${set_install_dir}/.${this_name}"
    else
        set_install_dir="${set_install_dir}/${this_name}"
    fi
fi


# Print messages in color
cl() {
    tput setaf "${1}"
    [ "${3:-}" == "1" ] && tput bold
    printf "${2}"
    tput sgr0
}

# Logo and info
print_logo() {
    cl 6 ' _____     ______     __  __     ______   __     __        \n';
    cl 6 '/\  __ .  /\  ___\   /\ \/\ \   /\__  _\ /\ \   /\ \       \n';
    cl 6 '\ \ \/\ \ \ \ \____  \ \ \_\ \  \/_/\ \/ \ \ \  \ \ \____  \n';
    cl 6 ' \ \____-  \ \_____\  \ \_____\    \ \_\  \ \_\  \ \_____\ \n';
    cl 6 '  \/____/   \/_____/   \/_____/     \/_/   \/_/   \/_____/ \n';
    cl 3 '                         A docker-compose utility for devs.\n';
    cl 3 "    Copyright (c) $(date +%Y) Faiyaz Haider under the MIT License.\n" 1;
}

# If command runs successfully, then proceed, else exit out of the script
if_cmd_success() {
    if error=$( { $1; } 3>&1 1>&2 2>&3 ); then
        cl 2 "$2.\n"
    else
        cl 1 "$error\n"
        exit 1
    fi
}

# The command script
print_command_script() {
    cat << EOS
#!/bin/bash
set -euo pipefail

export ${this_name}_script_dir="${script_dir}"
export ${this_name}_script="${set_script}"
export ${this_name}_libs="${set_libs_dir}"
export ${this_name}_root="${set_install_dir}"

# Print messages in color
cl() {
    tput setaf "\$1"
    [ "\${3:-}" == "1" ] && tput bold
    printf "\$2"
    tput sgr0
}

# Pass down variables to calling scripts
get_var() {
    var=\$1; [ "\${!var:-}" ] && echo \${!var}
}

# Update ${this_name} script
self_update() {
    \${${this_name}_root}/install.sh \${${this_name}_script_dir} \${${this_name}_libs} \$(dirname \${${this_name}_root})
    if [ -f "/tmp/${this_name}" ]; then
        cl 3 "Updating the script...\n" 1
        mv /tmp/${this_name} \${${this_name}_script}
        chmod 755 \${${this_name}_script}
        cl 7 "Done."; cl 2 " √\n"
        return 0
    fi
}

# Spit our general info
generic_info() {
    cl 7 "Usage: " 1;
    cl 7 "${this_name} ["; cl 3 "options" 1; cl 7 "] "
    cl 7 "["; cl 3 "commands" 1; cl 7 "] "
    cl 7 "["; cl 3 "arguments" 1; cl 7 "]\n"
    cl 7 "\n"
    cl 7 "Please visit "; cl 4 "${remote_repo_url%.git} " 1; cl 7 "for more info and usage details.\n"
    cl 7 "Copyright (c) "; cl 6 "\$(date +%Y) " 1; cl 7 "Faiyaz Haider under the "; cl 6 "MIT " 1; cl 7 "License.\n"
}

set_${this_name}_location() {
    if [ -d "\$1" ]; then
        cd \$1
        if git rev-parse --git-dir 2>/dev/null 1>&2; then
            find=\$(grep -E -o -m 1 -e "^export ${this_name}_libs=[\\'\\"](.+)?[\\'\\"]\\$" \${${this_name}_script})
            sed -i.bak -e "s#\$find#export ${this_name}_root=\\"\${1%/}\\"#" \${${this_name}_script} && rm -f \${${this_name}_script}.bak
        fi
    fi
}

set_${this_name}_lib_location() {
    if [ -d "\$1" ]; then
        find=\$(grep -E -o -m 1 -e "^export ${this_name}_libs=[\\'\\"](.+)?[\\'\\"]\\$" \${${this_name}_script})
        sed -i.bak -e "s#\$find#export ${this_name}_libs=\\"\${1%/}\\"#" \${${this_name}_script} && rm -f \${${this_name}_script}.bak
    fi
}

project_exists() {
    projects=(\$(echo \${PROJECTS//:/ }))
    [[ "\${projects[@]}" =~ "\${1}" ]] && return 0 || return 1
}

get_project_by_key() {
    projects=(\$(echo \${PROJECTS//:/ }))
	if (( "\${1:-}" > 0 )); then
        project=\${projects["\$(( \${1:-} - 1 ))"]}
        [ "\${project:-}" ] && echo \$project || return 1
    else
        return 1
    fi
}

get_host_ip() {
    # Determines users private IP only if Darwin/Mac or GNU/Linux.
	if [ "\$(uname)" == "Darwin" ]; then
		echo \$(ipconfig getifaddr en0)
	elif [ "\$(expr substr \$(uname -s) 1 5)" == "Linux" ]; then
		echo \$(hostname -I)
	elif [ "\$(expr substr \$(uname -s) 1 10)" == "MINGW32_NT" ] || [ "\$(expr substr \$(uname -s) 1 10)" == "MINGW64_NT" ]; then
		# TODO: Need to figure this out for windows users.
		echo "Sorry unable to get IP."
	else
	    return 1
	fi
}

get_version() {
    cd \$dcutil_root
    version=\$(git describe --always --tags)
    sha1=\$(git rev-parse HEAD)
    release_date=\$(git log -1 --format=%ai \$version)
    cl 3 " DCUTIL\n" 1
    cl 7 " Version: " 1; cl 2 "\${version}\n" 1
    cl 7 " Released: " 1; cl 2 "\${release_date:0:10}\n" 1
    cl 7 " SHA-1: " 1; cl 2 "\${sha1}\n" 1
}

if [ -d "\$${this_name}_root" ]; then
    if [ "\$#" == 0 ]; then
        generic_info
    else
        arg1=\${1:-}
        if [ "\$arg1" == "-u" -o "\$arg1" == "--update" ]; then
            self_update
        elif [  "\$arg1" == "--ip" ]; then
            if get_host_ip > /dev/null 2>&1; then
                get_host_ip
            fi
        elif [ "\$arg1" == "-r" -o "\$arg1" == "--remove" ]; then
            cl 1 "Are you sure you want to remove "; cl 7 "${this_title} " 1; cl 1 "from this machine ?\n"
            select choice in "Yes" "No"; do
                case \$choice in
                    Yes ) rm -rf \${${this_name}_root} && rm -f ${man_dir}/man1/${this_name}.1 && rm -- "\${${this_name}_script}"
                        cl 7 "${this_title} " 1; cl 6 "is now removed from this machine.\n"
                        cl 7 "Thank you for using. Goodbye.\n"
                        break;;
                    No )  exit;;
                    * ) echo "Please enter 1 for Yes or 2 for No.";;
                esac
            done
        elif [ "\$arg1" == "-h" -o "\$arg1" == "--help" -o "\$arg1" == "--man" ]; then
            man "\${${this_name}_root}/share/man/man1/dcutil.1"
        elif [ "\$arg1" == "-v" -o "\$arg1" == "--version" ]; then
            get_version
        elif [ "\$arg1" == "--var" ]; then
            [ "\${2:-}" ] && get_var \$2
        elif [ "\$arg1" == "--set-libs" ]; then
            if [ -d "\${2:-}" -a -f "\${2:-}/.env" -a -d "\${2:-}/docker-compose" ]; then
                set_dcutil_lib_location \$2
            else
                cl 1 "Argument 2 must be a valid dcutil libs directory.\n"
                cl 7 "A valid dcutil libs dir must contain an .env file and a docker-compose folder.\n"
                exit 1
            fi
        elif [ -d "\$${this_name}_libs" -a -f "\$${this_name}_libs/.env" -a -d "\$${this_name}_libs/docker-compose" ]; then
            (
                cd \${${this_name}_libs}/docker-compose
                [ -f "\${${this_name}_libs}/.env" ] && export \$(cat "\${${this_name}_libs}/.env" | grep -v ^\# | xargs)
                self_make="eval make -f \${${this_name}_root}/Makefile -I \${${this_name}_root}"

                if [ "\$arg1" == "-q" -o "\$arg1" == "--quiet" ]; then
                    quiet=true
                    shift
                    arg1=\$1
                fi

                one_project_num='^[0-9]+\$'
                one_project_name='^p='
                some_project_nums='^[0-9]+[0-9:]+[0-9]\$'
                all_projects='^(--all|-a)\$'
                if [[ \$arg1 =~ \$one_project_num ]]; then
                    num="true"
                    projects=("\$arg1")
                    shift
                elif [[ \$arg1 =~ \$some_project_nums ]]; then
                    num="true"
                    projects=(\$(echo \${arg1//:/ }))
                    shift
                elif [[ \$arg1 =~ \$one_project_name ]]; then
                    num="false"
                    arg1=\${arg1#p=}
                    projects=("\$arg1")
                    shift
                elif [[ \$arg1 =~ \$all_projects ]]; then
                    num="false"
                    projects=(\$(echo \${PROJECTS//:/ }))
                    shift
                else
                    num="false"
                    if project_exists \$arg1 || (( "\$#" > 1 )); then
                        projects=("\$arg1")
                        shift
                    else
                        projects="false"
                    fi
                fi

                first_arg="\${1:-}"
                other_args="\${@:2}"

                if [[ \$first_arg == "dc_"* ]]; then
                    pattern="(login|cmd)"
                    [[ ! \$first_arg =~ \$pattern ]] && other_args="args='\${@:2}'"
                fi

                if [ "\$projects" != "false" ]; then
                    total_projects="\${#projects[@]}"
                    (( "\$total_projects" > 1 )) && total_break=\$((\$total_projects - 1)) || total_break=0
                    for i in "\${!projects[@]}"; do
                        if [ "\$num" == "true" ]; then
                            if \$(get_project_by_key \${projects[\$i]} 2>/dev/null 1>&2); then
                                title="\$(get_project_by_key \${projects[\$i]})"
                                project="p=\${title}"
                            else
                                cl 1 "Invalid key \${projects[\$i]}\n"
                                exit 1
                            fi
                        else
                            title=\${projects[\$i]}
                            project="p=\${title}"
                        fi

                        (( "\$total_break" >= "\$i" )) && cl 8 "\n----------------[ " 1; cl 6 "Project: " 1; cl 6 "\${title}" 1;cl 8 " ]----------------\n" 1

                        call="\${self_make} \${project} \${first_arg} \${other_args:-}"
                        [ "\${quiet:-}" == "true" ] && \${call} 2>&1 >/dev/null || \${call}
                    done
                else
                    call="\${self_make} \${first_arg} \${other_args:-}"
                    [ "\${quiet:-}" == "true" ] && \${call} 2>&1 >/dev/null || \${call}
                fi
            )
        else
            cl 1 "Current set libs directory is not a valid dcutil libs directory.\n"
            cl 7 "Please use dcutil --set-libs <dcutil-libs-dir-name> to set a correct libs dir first.\n"
            exit 1
        fi
    fi
else
    cl 1 "${this_title} project could not be located\n"
    cl 3 "What would you like to do ?\n"
    select choice in "Clone from git repo" "Change directory" "Nothing"; do
        case \$choice in
            'Clone from git repo' )
                    cl 3 "Where would you like to place ${this_title} project: (Default \$${this_name}_script_dir)\n"
                    read install_dir
                    install_dir=\${install_dir:-\$${this_name}_script_dir}

                    # Verify directory exist
                    until [ -d "\${install_dir/#\~/\$HOME}" ]
                    do
                        cl 1 "Unable to find the directory '\${install_dir}', please try again.\n"
                        cl 8 "Check the spelling and make sure the directory exist.\n"
                        read install_dir
                        install_dir=\${install_dir:-\$${this_name}_script_dir}
                    done
                    install_dir=\${install_dir%/}
                    cl 6 "Cloning ${this_title} in directory \${install_dir}\n"
                    if [ "\$install_dir" == "\$${this_name}_script_dir" ] || [[ "\$install_dir" = *"bin"* ]]; then
                        install_dir="\${install_dir}/.${this_name}"
                    else
                        install_dir="\${install_dir}/${this_name}"
                    fi
                    git clone ${remote_repo_url} \${install_dir}
                    cd \${install_dir}
                    git submodule update --init --recursive
                    set_${this_name}_location \${install_dir}
                    cl 2 "Cloned.\n\n"
                    exec "\$0" "\$@"
                    break;;
            'Change directory' )
                    while true; do
                        cl 3 "What is the new location of the ${this_title} project? Please enter full path.\n"
                        read new_root_dir
                        new_root_dir=\${new_root_dir/#\~/\$HOME}

                        # Verify directory exist
                        until [ -d "\${new_root_dir}" ]
                        do
                            cl 1 "Unable to find the directory '\${new_root_dir}', please try again.\n"
                            cl 8 "Check the spelling and make sure the directory exist.\n"
                            read new_root_dir
                            new_root_dir=\${new_root_dir/#\~/\$HOME}
                        done
                        new_root_dir=\${new_root_dir%/}

                        if set_${this_name}_location \${new_root_dir}; then
                            cl 2 "Directory changed.\n\n"
                            exec "\$0" "\$@"
                            break
                        else
                            cl 1 "\${new_root_dir} doesn't seem to be the correct directory for ${this_title}.\n"
                            continue
                        fi
                    done;;
            Nothing )
                    cl 7 "\nYou need to have the "; cl 7 "${this_title} " 1; cl 1 "repo for the command "; cl 7 "${this_name} " 1; cl 1" to work.\n"
                    cl 7 "You can manually clone the project using "; cl 3 "git clone ${remote_repo_url}.\n" 1
                    cl 7 "Make sure to update "; cl 7 "${this_title} " 1;
                    cl 7 "Goodbye.\n\n"
                    exit;;
            * )     echo "Please enter 1 for clone, 2 to change to new location, 3 for do nothing.";;
        esac
    done
fi
EOS
}

# Business... Installation
if [ -z "${exist:-}" ]; then
    # Repo...
    if [ -d ${set_install_dir} -a -n "$(ls -A ${set_install_dir} 2>/dev/null)" ]; then
        cl 1 "${this_title} repo already exists in ${set_install_dir}.\n"
    else
        # Adding repo
        cl 3 "Cloning ${this_title}...\n" 1
        if_cmd_success "git clone ${remote_repo_url} ${set_install_dir}" "${this_title} cloned."
        cd "${set_install_dir}" && git submodule update --init --recursive
    fi

    # Command script...
    if [ -f "${set_script}" ]; then
        cl 1 "${this_title} command script already exists in ${script_dir}.\n"
    else
        # Set the command script
        cl 3 "Adding '${this_name}' command in your ${script_dir} directory.\n"
        print_command_script > "${set_script}"
        chmod 755 "${set_script}"

        # If path exists and writable then add symbolic link for manual
        if [[ "$(manpath)" == *"${man_dir}"* ]] && [ -w "${man_dir}" ]; then
            mkdir -p "${man_dir}/man1"
            ln -s ${set_install_dir}/share/man/man1/${this_name}.1  ${man_dir}/man1/ 2>/dev/null 1>&2
        fi

        cl 2 "Done. Make sure "; cl 7 "${script_dir} " 1; cl 2 "is in your PATH.\n\n"
        print_logo
    fi
fi

# Update only if call made from command script
if [ "${exist:-}" == "true" ] && [[ $(ps -o args= $PPID) = *"${set_script}"* ]]; then

    if cd "${set_install_dir}" 2>/dev/null 1>&2 && git rev-parse --git-dir 2>/dev/null 1>&2 && git ls-remote -h ${remote_repo_url} 2>/dev/null 1>&2; then
        if git checkout -q HEAD^ && git checkout -fq master; then
            currentVersion=$(git describe --tags)
            git fetch -qt --all --prune && git pull -q
            latestVersion=$(git describe --tags $(git rev-list --tags --max-count=1))
            if [ "${currentVersion}" != "${latestVersion}" ]; then
                cl 3 "Updating the repo...\n" 1
                if git checkout -q ${latestVersion}; then
                    cl 7 "Done."; cl 2 " √\n"
                fi
            elif [ "${currentVersion}" == "${latestVersion}" ]; then
                cl 7 "Repo: "; cl 2 "Up to date.\n"
            else
                cl 7 "Script: "; cl 1 "Unable to update.\n"
            fi
        fi
    fi

    if [ "$(print_command_script)" != "$(cat ${set_script})" ]; then
        print_command_script > "/tmp/${this_name}"
    else
        cl 7 "Script: "; cl 2 "up to date.\n"
    fi
fi
