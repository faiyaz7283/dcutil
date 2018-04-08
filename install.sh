#!/bin/bash

# Minimum args requirement checks
if (( "$#" < 2 )); then
    echo "Not enough arguments."
    exit 1
else
    remote_repo_url="https://github.com/faiyaz7283/dcutil.git"
    local_repo_name=".dcutil"
    this_name="dcutil"
    this_title="DCUTIL"

    # Arg 1 dir check
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
        install_dir="${2%/}"
    else
        install_dir="${program_dir}"
    fi
fi

# Print messages in color
print_cl() {
    tput setaf "${1}"; printf "${2}" tput sgr0
}

# Logo and info
print_logo() {
    print_cl 6 ' _____     ______     __  __     ______   __     __        \n';
    print_cl 6 '/\  __ .  /\  ___\   /\ \/\ \   /\__  _\ /\ \   /\ \       \n';
    print_cl 6 '\ \ \/\ \ \ \ \____  \ \ \_\ \  \/_/\ \/ \ \ \  \ \ \____  \n';
    print_cl 6 ' \ \____-  \ \_____\  \ \_____\    \ \_\  \ \_\  \ \_____\ \n';
    print_cl 6 '  \/____/   \/_____/   \/_____/     \/_/   \/_/   \/_____/ \n';
    print_cl 3 '                         A docker-compose utility for devs.\n';
    print_cl 3 "    Copyright (c) $(date +%Y) Faiyaz Haider under the MIT License.\n";
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
export ${this_name}_libs="${libs_dir}"
export ${this_name}_root="$1"
if [ -z "\$${this_name}_root" ]; then
    export ${this_name}_root="\${program_dir}/${local_repo_name}"
fi

# Update ${this_name} script
self_update() {
    \${${this_name}_root}/install.sh \${program_dir} \${${this_name}_libs} \$(dirname \${${this_name}_root})
    if [ -f "/tmp/${this_name}" ]; then
        echo "Updating the script."
        mv /tmp/${this_name} \${program_dir}/${this_name}
        chmod 755 \${program_dir}/${this_name}
        tput setaf 7; printf "Done."; tput setaf 2; printf " √\n"; tput sgr0
        return 0
    fi
}

# Spit our general info
generic_info() {
    g="man"
    b=\$(tput bold)
    n=\$(tput sgr0)
    line=\$(printf "=%.0s" {1..25})
    echo "\${b}Usage:\${n} ${this_name} [ options ] [ parameters ] <target>"
    echo "\${line}"
    echo "Please visit \${b}${remote_repo_url}\${n} for more info and usage details."
    echo "Copyright (c) \$(date +%Y) Faiyaz Haider under MIT License."
}

set_${this_name}_location() {
    if [ -d "\$1" ]; then
        cd \$1
        if git rev-parse --git-dir 2>/dev/null 1>&2; then
            if [[  \$(git remote get-url origin) = *"faiyaz7283/${this_name}"* ]]; then
                if [ "\$1" != "\${program_dir}/${local_repo_name}" -a "\$1" != "\$${this_name}_root" ]; then
                    find=\`grep -E -o -m 1 -e "^export ${this_name}_libs=[\\w\\d\\'\\"]+\$" \${BASH_SOURCE[0]}\`
                    sed -i.bak -e "s#\$find#export ${this_name}_root=\\"\$1\\"#" \${BASH_SOURCE[0]} && rm -f \${BASH_SOURCE[0]}.bak
                fi
            fi
        fi
    fi
}

set_${this_name}_lib_location() {
    if [ -d "\$1" ]; then
        find=\`grep -E -o -m 1 -e "^export ${this_name}_libs=[\\w\\d\\'\\"]+" \${BASH_SOURCE[0]}\`
        sed -i.bak -e "s#\$find#export ${this_name}_libs=\\"\$1\\"#" \${BASH_SOURCE[0]} && rm -f \${BASH_SOURCE[0]}.bak
    fi
}

project_exists() {
    projects=(\`echo \${PROJECTS//:/ }\`)
    [[ "\${projects[@]}" =~ "\${1}" ]] && return 0 || return 1
}

get_project_by_key() {
    projects=(\`echo \${PROJECTS//:/ }\`)
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
                tput setaf 1; printf "Are you sure you want to remove ${this_title} from this machine ?\n"; tput sgr0
                select choice in "Yes" "No"; do
                    case \$choice in
                        Yes ) rm -rf \${${this_name}_root} && rm -- "\${BASH_SOURCE[0]}"
                            tput setaf 6; printf "${this_title} is now removed from this machine.\n"
                            tput setaf 7; printf "Thank you for using. Goodbye.\n"; tput sgr0
                            break;;
                        No )  exit;;
                        * ) echo "Please enter 1 for Yes or 2 for No.";;
                    esac
                done
            elif [ "\$1" == "-h" -o "\$1" == "--help" -o "\$1" == "--man" ]; then
                \${self_make} help
            elif [ "\$1" == "-v" -o "\$1" == "--version" ]; then
                \${self_make} version
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
                            project="p=\`get_project_by_key \$1\`"
                            shift
                        else
                            tput setaf 1; printf "Invalid key \$1\n"; tput sgr0
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
        tput setaf 1; printf "Missing ${this_title} libs directory.\n"; tput sgr0
        exit 1
    fi
else
    tput setaf 1; printf "${this_title} project could not be located\n"
    tput setaf 3; printf "What would you like to do ?\n"; tput sgr0
    select choice in "Clone from git repo" "Change directory" "Nothing"; do
        case \$choice in
            'Clone from git repo' )
                    tput setaf 3; printf "Where would you like to place ${this_title} project: (Default \$program_dir)\n"; tput sgr0
                    read ${this_name}_install_dir
                    ${this_name}_install_dir=\${${this_name}_install_dir:-\$program_dir}

                    # Verify directory exist
                    until [ -d "\${${this_name}_install_dir/#\~/\$HOME}" ]
                    do
                        tput setaf 1; printf "Unable to find the directory '\${${this_name}_install_dir}', please try again.\n"
                        tput setaf 8; printf "Check the spelling and make sure the directory exist.\n"; tput sgr0
                        read ${this_name}_install_dir
                        ${this_name}_install_dir=\${${this_name}_install_dir:-\$program_dir}
                    done
                    ${this_name}_install_dir=\${${this_name}_install_dir%/}
                    tput setaf 6; printf "Cloning ${this_title} in directory \${${this_name}_install_dir}\n"; tput sgr0
                    git clone ${remote_repo_url} \${${this_name}_install_dir}/${local_repo_name}
                    cd \${${this_name}_install_dir}/${local_repo_name}
                    git submodule update --init --recursive

                    set_${this_name}_location \${${this_name}_install_dir}/${local_repo_name}
                    tput setaf 2; printf "Cloned.\n\n"; tput sgr0
                    exec "\$0" "\$@"
                    break;;
            'Change directory' )
                    while true; do
                        tput setaf 3; printf "What is the new location of the ${this_title} project? Please enter full path including the ${this_title} root directory.\n"; tput sgr0
                        read new_${this_name}_root_dir
                        new_${this_name}_root_dir=\${new_${this_name}_root_dir/#\~/\$HOME}

                        # Verify directory exist
                        until [ -d "\${new_${this_name}_root_dir}" ]
                        do
                            tput setaf 1; printf "Unable to find the directory '\${new_${this_name}_root_dir}', please try again.\n"
                            tput setaf 8; printf "Check the spelling and make sure the directory exist.\n"; tput sgr0
                            read new_${this_name}_root_dir
                            new_${this_name}_root_dir=\${new_${this_name}_root_dir/#\~/\$HOME}
                        done
                        new_${this_name}_root_dir=\${new_${this_name}_root_dir%/}

                        if set_${this_name}_location \${new_${this_name}_root_dir}; then
                            tput setaf 2; printf "Directory changed.\n\n"; tput sgr0
                            exec "\$0" "\$@"
                            break
                        fi

                        tput setaf 1; printf "\${new_${this_name}_root_dir} doesn't seem to be the correct directory for ${this_title}.\n"; tput sgr0
                        continue
                    done;;
            Nothing )
                    tput setaf 1; printf "\nYou need to have the ${this_title} repo for the command ${this_name} to work.\n"; tput sgr0
                    tput setaf 7; printf "You can manually clone the project at ${remote_repo_url}.\n"; tput sgr0
                    tput setaf 7; printf "Goodbye.\n\n"; tput sgr0
                    exit;;
            * )     echo "Please enter 1 for clone, 2 to change to new location, 3 for do nothing.";;
        esac
    done
fi
EOS
}

# Business...
# Add project if it doesn't exist.
if cd "${install_dir}/${local_repo_name}" 2>/dev/null 1>&2 && git rev-parse --git-dir 2>/dev/null 1>&2 && git ls-remote -h ${remote_repo_url} 2>/dev/null 1>&2; then
    if git fetch -q --all --prune && git pull -q; then
        print_cl 7 "Repo: "; print_cl 2 "up to date.\n"
    fi
else
    print_cl 7 "${this_title} does not exist."
    print_cl 3 "Cloning ${this_title} from git repo...\n"
    if_cmd_success "git clone ${remote_repo_url} ${install_dir}/${local_repo_name}" "${this_title} cloned."
    cd "${install_dir}/${local_repo_name}" && git submodule update --init --recursive
fi

if [ ! -f "${program_dir}/${this_name}" ]; then
    # Set the command
    print_cl 3 "Adding the '${this_name}' command in your ${program_dir} directory.\n"
    print_command_script "${install_dir}/${local_repo_name}" > "${program_dir}/${this_name}"
    chmod 755 "${program_dir}/${this_name}"
    print_cl 2 "Done. Make sure ${program_dir} is in your PATH.\n\n"
    print_logo
elif [ "$(print_command_script ${install_dir}/${local_repo_name})" != "$(cat ${program_dir}/${this_name})" ]; then
    print_cl 7 "Script: "; print_cl 1 "outdated.\n"
    print_command_script "${install_dir}/${local_repo_name}" > "/tmp/${this_name}"
else
    print_cl 7 "Script: "; print_cl 2 "up to date.\n"
fi
