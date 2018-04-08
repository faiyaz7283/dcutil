#!/bin/bash

# Minimum args requirement checks
if (( "$#" < 2 )); then
    echo "Not enough arguments."
    exit 1
else
    # Arg 1 check
    if [ "$1" -a -d "$1" ]; then
        program_dir="${1%/}"
    else
        echo "Argument 1 is missing or not a valid directory."
        exit 1
    fi

    # Arg 2 check
    if [ "$2" -a -d "$2" ]; then
        libs_dir="${2%/}"
    else
        echo "Argument 2 is missing or not a valid directory."
        exit 1
    fi

    # Arg 3 check
    if [ "$3" -a -d "$3" ]; then
        install_dir="${3%/}"
    else
        install_dir="${program_dir}"
    fi
fi

# Variables
this_name="dcutil"
this_title="DCUTIL"
this_script="${program_dir}/${this_name}"
remote_repo_url="https://github.com/faiyaz7283/dcutil.git"
local_repo_name=".dcutil"
local_repo_root="${install_dir}/${local_repo_name}"

# Print messages in color
print_cl() {
    tput setaf "${1}"
    [ "$3" -a "$3" == "1" ] && tput bold
    printf "${2}"
    tput sgr0
}

# Logo and info
print_logo() {
    print_cl 6 ' _____     ______     __  __     ______   __     __        \n';
    print_cl 6 '/\  __ .  /\  ___\   /\ \/\ \   /\__  _\ /\ \   /\ \       \n';
    print_cl 6 '\ \ \/\ \ \ \ \____  \ \ \_\ \  \/_/\ \/ \ \ \  \ \ \____  \n';
    print_cl 6 ' \ \____-  \ \_____\  \ \_____\    \ \_\  \ \_\  \ \_____\ \n';
    print_cl 6 '  \/____/   \/_____/   \/_____/     \/_/   \/_/   \/_____/ \n';
    print_cl 3 '                         A docker-compose utility for devs.\n';
    print_cl 3 "    Copyright (c) $(date +%Y) Faiyaz Haider under the MIT License.\n" 1;
}

# If command runs successfully, then proceed, else exit out of the script
if_cmd_success() {
    if error=$( { $1; } 3>&1 1>&2 2>&3 ); then
        print_cl 2 "$2.\n"
    else
        print_cl 1 "$error\n"
        exit 1
    fi
}

# The command script
print_command_script() {
    cat << EOS
#!/bin/bash

export program_dir="${program_dir}"
this_script="\${program_dir}/${this_name}"
export ${this_name}_libs="${libs_dir}"
export ${this_name}_root="$1"

# Print messages in color
print_cl() {
    tput setaf "\$1"
    [ "\$3" -a "\$3" == "1" ] && tput bold
    printf "\$2"
    tput sgr0
}

# Update ${this_name} script
self_update() {
    \${${this_name}_root}/install.sh \${program_dir} \${${this_name}_libs} \$(dirname \${${this_name}_root})
    if [ -f "/tmp/${this_name}" ]; then
        print_cl 3 "Updating the script...\n" 1
        mv /tmp/${this_name} \${this_script}
        chmod 755 \${this_script}
        print_cl 7 "Done."; print_cl 2 " √\n"
        return 0
    fi
}

# Spit our general info
generic_info() {
    print_cl 7 "Usage: " 1;
    print_cl 7 "${this_name} ["; print_cl 3 "options" 1; print_cl 7 "] "
    print_cl 7 "["; print_cl 3 "parameters" 1; print_cl 7 "] "
    print_cl 7 "<"; print_cl 3 "target" 1; print_cl 7 ">\n"
    print_cl 7 "\n"
    print_cl 7 "Please visit "; print_cl 4 "${remote_repo_url%.git} " 1; print_cl 7 "for more info and usage details.\n"
    print_cl 7 "Copyright (c) "; print_cl 6 "\$(date +%Y) " 1; print_cl 7 "Faiyaz Haider under the "; print_cl 6 "MIT " 1; print_cl 7 "License.\n"
}

set_${this_name}_location() {
    if [ -d "\$1" ]; then
        cd \$1
        if git rev-parse --git-dir 2>/dev/null 1>&2; then
            if [[  \$(git remote get-url origin) = *"faiyaz7283/${this_name}"* ]]; then
                if [ "\$1" != "\${program_dir}/${local_repo_name}" -a "\$1" != "\$${this_name}_root" ]; then
                    find=\$(grep -E -o -m 1 -e "^export ${this_name}_libs=[\\w\\d\\'\\"]+\$" \${this_script})
                    sed -i.bak -e "s#\$find#export ${this_name}_root=\\"\$1\\"#" \${this_script} && rm -f \${this_script}.bak
                fi
            fi
        fi
    fi
}

set_${this_name}_lib_location() {
    if [ -d "\$1" ]; then
        find=\$(grep -E -o -m 1 -e "^export ${this_name}_libs=[\\w\\d\\'\\"]+" \${this_script})
        sed -i.bak -e "s#\$find#export ${this_name}_libs=\\"\$1\\"#" \${this_script} && rm -f \${this_script}.bak
    fi
}

project_exists() {
    projects=(\$(echo \${PROJECTS//:/ }))
    [[ "\${projects[@]}" =~ "\${1}" ]] && return 0 || return 1
}

get_project_by_key() {
    projects=(\$(echo \${PROJECTS//:/ }))
	if (( "\${1}" > 0 )); then
        project=\${projects["\$(( \${1} - 1 ))"]}
        [ "\$project" ] && echo \$project || return 1
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

if [ -d "\$${this_name}_root" ]; then
    if [ "\$${this_name}_libs" -a -d "\$${this_name}_libs"  ]; then
        (
            cd \${${this_name}_libs}
            [ -f ".env" ] && export \$(cat .env | grep -v ^\# | xargs)
            self_make="eval make -f \${${this_name}_root}/Makefile -I \${${this_name}_root}"
            if [ "\$1" == "-u" -o "\$1" == "--update" ]; then
                self_update
            elif [  "\$1" == "--ip" ]; then
                if get_host_ip > /dev/null 2>&1; then
                    get_host_ip
                fi
            elif [ "\$1" == "-r" -o "\$1" == "--remove" ]; then
                print_cl 1 "Are you sure you want to remove "; print_cl 7 "${this_title} " 1; print_cl 1 "from this machine ?\n"
                select choice in "Yes" "No"; do
                    case \$choice in
                        Yes ) rm -rf \${${this_name}_root} && rm -- "\${this_script}"
                            print_cl 7 "${this_title} " 1; print_cl 6 "is now removed from this machine.\n"
                            print_cl 7 "Thank you for using. Goodbye.\n"
                            break;;
                        No )  exit;;
                        * ) echo "Please enter 1 for Yes or 2 for No.";;
                    esac
                done
            elif [ "\$1" == "-h" -o "\$1" == "--help" -o "\$1" == "--man" ]; then
                \${self_make} help
            elif [ "\$1" == "-v" -o "\$1" == "--version" ]; then
                cd \$dcutil_root
                version=\$(git describe --always --tags)
                sha1=\$(git rev-parse HEAD)
                release_date=\$(git log -1 --format=%ai \$version)
                print_cl 3 " DCUTIL\n" 1
                print_cl 7 " - Version: "; print_cl 2 "\${version}\n" 1
                print_cl 7 " - Released: "; print_cl 2 "\${release_date:0:10}\n" 1
                print_cl 7 " - SHA-1: "; print_cl 2 "\${sha1}\n" 1
            else
                if [ "\$#" == 0 ]; then
                    generic_info
                else
                    if [ "\$1" == "-q" -o "\$1" == "--quiet" ]; then
                        quiet=true
                        shift
                    fi

                    pattern='^[0-9]+\$'
                    if [[ \$1 =~ \$pattern ]]; then
                        if get_project_by_key \$1 2>/dev/null 1>&2; then
                            project="p=\$(get_project_by_key \$1)"
                            shift
                        else
                            print_cl 1 "Invalid key \$1\n"
                            exit 1
                        fi
                    elif [[ ! \$1 =~ "=" ]]; then
                        if project_exists \$1 || (( "\$#" > 1 )); then
                            project="p=\$1"
                            shift
                        fi
                    fi

                    if [ "\$quiet" == true ]; then
                        \${self_make} \$project "\$@" 2>&1 >/dev/null
                    else
                        \${self_make} \$project "\$@"
                    fi
                fi
            fi
        )
    else
        print_cl 1 "Missing ${this_title} libs directory.\n"
        exit 1
    fi
else
    print_cl 1 "${this_title} project could not be located\n"
    print_cl 3 "What would you like to do ?\n"
    select choice in "Clone from git repo" "Change directory" "Nothing"; do
        case \$choice in
            'Clone from git repo' )
                    print_cl 3 "Where would you like to place ${this_title} project: (Default \$program_dir)\n"
                    read ${this_name}_install_dir
                    ${this_name}_install_dir=\${${this_name}_install_dir:-\$program_dir}

                    # Verify directory exist
                    until [ -d "\${${this_name}_install_dir/#\~/\$HOME}" ]
                    do
                        print_cl 1 "Unable to find the directory '\${${this_name}_install_dir}', please try again.\n"
                        print_cl 8 "Check the spelling and make sure the directory exist.\n"
                        read ${this_name}_install_dir
                        ${this_name}_install_dir=\${${this_name}_install_dir:-\$program_dir}
                    done
                    ${this_name}_install_dir=\${${this_name}_install_dir%/}
                    print_cl 6 "Cloning ${this_title} in directory \${${this_name}_install_dir}\n"
                    git clone ${remote_repo_url} \${${this_name}_install_dir}/${local_repo_name}
                    cd \${${this_name}_install_dir}/${local_repo_name}
                    git submodule update --init --recursive

                    set_${this_name}_location \${${this_name}_install_dir}/${local_repo_name}
                    print_cl 2 "Cloned.\n\n"
                    exec "\$0" "\$@"
                    break;;
            'Change directory' )
                    while true; do
                        print_cl 3 "What is the new location of the ${this_title} project? Please enter full path including the ${this_title} root directory.\n"
                        read new_${this_name}_root_dir
                        new_${this_name}_root_dir=\${new_${this_name}_root_dir/#\~/\$HOME}

                        # Verify directory exist
                        until [ -d "\${new_${this_name}_root_dir}" ]
                        do
                            print_cl 1 "Unable to find the directory '\${new_${this_name}_root_dir}', please try again.\n"
                            print_cl 8 "Check the spelling and make sure the directory exist.\n"
                            read new_${this_name}_root_dir
                            new_${this_name}_root_dir=\${new_${this_name}_root_dir/#\~/\$HOME}
                        done
                        new_${this_name}_root_dir=\${new_${this_name}_root_dir%/}

                        if set_${this_name}_location \${new_${this_name}_root_dir}; then
                            print_cl 2 "Directory changed.\n\n"
                            exec "\$0" "\$@"
                            break
                        fi

                       print_cl 1 "\${new_${this_name}_root_dir} doesn't seem to be the correct directory for ${this_title}.\n"
                        continue
                    done;;
            Nothing )
                    print_cl 1 "\nYou need to have the "; print_cl 7 "${this_title} " 1; print_cl 1 "repo for the command "; print_cl 7 "${this_name} " 1; print_cl 1" to work.\n"
                    print_cl 7 "You can manually clone the project at "; print_cl 3 "${remote_repo_url}.\n" 1
                    print_cl 7 "Goodbye.\n\n"
                    exit;;
            * )     echo "Please enter 1 for clone, 2 to change to new location, 3 for do nothing.";;
        esac
    done
fi
EOS
}

# Business...
# Add project if it doesn't exist.
if cd "${local_repo_root}" 2>/dev/null 1>&2 && git rev-parse --git-dir 2>/dev/null 1>&2 && git ls-remote -h ${remote_repo_url} 2>/dev/null 1>&2; then
    if git fetch -q --all --prune && git pull -q; then
        print_cl 7 "Repo: "; print_cl 2 "up to date.\n"
    fi
else
    print_cl 1 "${this_title} does not exist.\n"
    print_cl 3 "Cloning ${this_title}...\n" 1
    if_cmd_success "git clone ${remote_repo_url} ${local_repo_root}" "${this_title} cloned."
    cd "${local_repo_root}" && git submodule update --init --recursive
fi

if [ ! -f "${this_script}" ]; then
    # Set the command
    print_cl 3 "Adding '${this_name}' command in your ${program_dir} directory.\n"
    print_command_script "${local_repo_root}" > "${this_script}"
    chmod 755 "${this_script}"
    print_cl 2 "Done. Make sure "; print_cl 7 "${program_dir} " 1; print_cl 2 "is in your PATH.\n\n"
    print_logo
elif [ "$(print_command_script ${local_repo_root})" != "$(cat ${this_script})" ]; then
    print_cl 7 "Script: "; print_cl 1 "outdated.\n"
    print_command_script "${local_repo_root}" > "/tmp/${this_name}"
else
    print_cl 7 "Script: "; print_cl 2 "up to date.\n"
fi
