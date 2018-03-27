#!/usr/bin/env bash

# Minimum args requirement checks
if (( "$#" < 2 )); then
    echo "Missing required argument."
    exit 1
else
    # Arg 1 dir check
    if [ "$1" -a -d "$1" ]; then
        program_dir="${1%/}"
    else
        echo "Argument 1 is missing or not a valid directory."
        exit 1
    fi

    # Arg 2 check
    if [ "$2" -a -d "$2" ]; then
        repo="https://github.com/faiyaz7283/dcutil.git"
        dcutil_install_dir="${2%/}"
    else
        echo "Argument 2 is missing or not a valid directory."
        exit 1
    fi
fi

# DCUTIL Logo and info
print_logo() {
    tput setaf 6
    echo ' _____     ______     __  __     ______   __     __       '
    echo '/\  __-.  /\  ___\   /\ \/\ \   /\__  _\ /\ \   /\ \      '
    echo '\ \ \/\ \ \ \ \____  \ \ \_\ \  \/_/\ \/ \ \ \  \ \ \____ '
    echo ' \ \____-  \ \_____\  \ \_____\    \ \_\  \ \_\  \ \_____\'
    echo '  \/____/   \/_____/   \/_____/     \/_/   \/_/   \/_____/'
    tput setaf 3
    echo '                         A docker-compose utility for devs.'
    echo "    Copyright (c) $(date +%Y) Faiyaz Haider under the MIT License."
}

# Print messages in color
print_cl() {
    tput setaf "${1}"
    printf "${2}"
    tput sgr0
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

# DCUTIL command
print_dcutil_call() {
    cat << EOS
#!/usr/bin/env bash

# Update self
self_update() {
    ./install.sh ${program_dir} \$(dirname \${dcutil_root})
    if [ -f "/tmp/dcutil" ]; then
        echo "Updating the script."
        mv /tmp/dcutil ${program_dir}/dcutil
        chmod 755 ${program_dir}/dcutil
        return 0
    fi
}

generic_info() {
    g="man"
    b=\$(tput bold)
    n=\$(tput sgr0)
    line=\$(printf "=%.0s" {1..25})
    echo "\${b}Usage:\${n} dcutil [ options ] [ parameters ] <target>"
    echo "\${line}"
    echo "Please visit \${b}https://github.com/faiyaz7283/dcutil\${n} for more info and usage details."
    echo "Copyright (c) \$(date +%Y) Faiyaz Haider under MIT License."
}

project_exists() {
    projects=(\`echo \${PROJECTS//:/ }\`)
    [[ "\${projects[@]}" =~ "\${1}" ]] && return 0 || return 1
}

get_project_by_key() {
    [ -f ".env" ] && export \$(cat .env | grep -v ^\\# | xargs)
    projects=(\`echo \${PROJECTS//:/ }\`)
	if (( "\${1}" > 0 )); then
        project=\${projects["\$(( \${1} - 1 ))"]}
        [ "\$project" ] && echo \$project || return 1
    else
        return 1
    fi
}

dcutil_root=${1}

if [ -d "\$dcutil_root" ]; then
    (
        cd \${dcutil_root}
        [ -f ".env" ] && export \$(cat .env | grep -v ^\\# | xargs)
        if [ "\$1" == "-u" -o "\$1" == "--update" ]; then
            self_update
        elif [ "\$1" == "-r" -o "\$1" == "--remove" ]; then
			tput setaf 1; printf "Are you sure you want to remove DCUTIL from this machine ?\n"; tput sgr0
			select choice in "Yes" "No"; do
				case \$choice in
					Yes ) rm -rf \${dcutil_root} && rm -- "\$0"
            			  tput setaf 6; printf "DCUTIL is now removed from this machine.\n"
            			  tput setaf 7; printf "Thank you for using. Goodbye.\n"; tput sgr0
						  break;;
					No )  exit;;
					* ) echo "Please enter 1 for Yes or 2 for No.";;
				esac
			done
		elif [ "\$1" == "-h" -o "\$1" == "--help" -o "\$1" == "--man" ]; then
            make help
        elif [ "\$1" == "-v" -o "\$1" == "--version" ]; then
            make version
        else
            if [ "\$#" == 0 ]; then
                generic_info
            else
                if [ "\$1" == "-q" -o "\$1" == "--quiet" ]; then
                    quiet=true
                    shift
                fi

                pattern='^[0-9]+$'
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
                    make \$project "\$@" 2>&1 >/dev/null
                else
                    make \$project "\$@"
                fi
            fi
        fi
    )
else
    tput setaf 1; printf "DCUTIL project could not be located\n"
    tput setaf 3; printf "What would you like to do ?\n"; tput sgr0
    select choice in "Clone from git repo" "Change directory" "Nothing"; do
        case \$choice in
            'Clone from git repo' )
                      tput setaf 3; printf "Where would you like to place DCUTIL project: (Default \$HOME)\n"; tput sgr0
                      read dcutil_install_dir
                      dcutil_install_dir=\${dcutil_install_dir:-\$HOME}

                      # Verify directory exist
                      until [ -d "\${dcutil_install_dir/#\~/\$HOME}" ]
                      do
                          tput setaf 1; printf "Unable to find the directory '\${dcutil_install_dir}', please try again.\n"
                          tput setaf 8; printf "Check the spelling and make sure the directory exist.\n"; tput sgr0
                          read dcutil_install_dir
                          dcutil_install_dir=\${dcutil_install_dir:-\$HOME}
                      done
                      dcutil_install_dir=\${dcutil_install_dir%/}
                      tput setaf 6; printf "Cloning DCUTIL in directory \${dcutil_install_dir}\n"; tput sgr0
                      git clone https://github.com/faiyaz7283/dcutil.git \${dcutil_install_dir}/dcutil
                      cd \${dcutil_install_dir}/dcutil
                      git submodule update --init --recursive
                      tput setaf 2; printf "Cloned.\n\n"; tput sgr0
                      exec "\$0" "\$@"
                      break;;
            'Change directory' )
                      while true; do
                          tput setaf 3; printf "What is the new location of the DCUTIL project? Please enter full path including the DCUTIL root directory.\n"; tput sgr0
                          read new_dcutil_root_dir
                          new_dcutil_root_dir=\${new_dcutil_root_dir/#\~/\$HOME}

                          # Verify directory exist
                          until [ -d "\${new_dcutil_root_dir}" ]
                          do
                              tput setaf 1; printf "Unable to find the directory '\${new_dcutil_root_dir}', please try again.\n"
                              tput setaf 8; printf "Check the spelling and make sure the directory exist.\n"; tput sgr0
                              read new_dcutil_root_dir
                              new_dcutil_root_dir=\${new_dcutil_root_dir/#\~/\$HOME}
                          done
                          new_dcutil_root_dir=\${new_dcutil_root_dir%/}
                          script_file="\$( cd \$( dirname \${BASH_SOURCE[0]} ) && pwd )/\$(basename \$0)"
                          cd \${new_dcutil_root_dir}

                          if git rev-parse --git-dir 2>/dev/null 1>&2; then
                              if [[  \$(git remote get-url origin) = *"faiyaz7283/dcutil"* ]]; then
                                  sed -i.bak -e "s#\${dcutil_root}#\${new_dcutil_root_dir}#" \$script_file && rm -f \${script_file}.bak
                                  tput setaf 2; printf "Updated to the new directory.\n\n"; tput sgr0
                                  exec "\$0" "\$@"
                                  break
                              fi
                          fi

                          tput setaf 1; printf "\${new_dcutil_root_dir} doesn't seem to be the correct directory for DCUTIL.\n"; tput sgr0
                          continue
                      done;;
            Nothing ) tput setaf 1; printf "\nYou need to have the DCUTIL repo for the command dcutil to work.\n"; tput sgr0
                      tput setaf 7; printf "You can manually clone the project at https://github.com/faiyaz7283/dcutil.git.\n"; tput sgr0
                      tput setaf 7; printf "Nothing to do. Goodbye.\n\n"; tput sgr0
                      exit;;
            * )       echo "Please enter 1 for clone, 2 to change to new location, 3 for do nothing.";;
        esac
    done
fi
EOS
}

# Business...
if [ "$repo" ]; then
    # Add DCUTIL project if doesn't exist.
    if cd "${dcutil_install_dir}/dcutil" 2>/dev/null 1>&2 && git rev-parse --git-dir 2>/dev/null 1>&2 && git ls-remote -h ${repo} 2>/dev/null 1>&2; then
        if git fetch -q --all --prune && git pull -q; then
            print_cl 7 "Repo: "; print_cl 2 "up to date.\n"
        fi
    else
        print_cl 3 "Cloning DCUTIL from git repo...\n"
        if_cmd_success "git clone ${repo} ${dcutil_install_dir}/dcutil" 'DCUTIL cloned.'
        cd "${dcutil_install_dir}/dcutil" && git submodule update --init --recursive
    fi
fi

if [ ! -f "${program_dir}/dcutil" ]; then
    # Set the dcutil command
    print_cl 3 "Adding the 'dcutil' command in your ${program_dir} directory.\n"
    print_dcutil_call "${dcutil_install_dir}/dcutil" > "${program_dir}/dcutil"
    chmod 755 "${program_dir}/dcutil"
    print_cl 2 "Done. Make sure ${program_dir} is in your PATH.\n\n"
    print_logo
elif [ "$(print_dcutil_call ${dcutil_install_dir}/dcutil)" != "$(cat ${program_dir}/dcutil)" ]; then
    print_cl 7 "Script: "; print_cl 1 "outdated.\n"
    print_dcutil_call "${dcutil_install_dir}/dcutil" > "/tmp/dcutil"
else
    print_cl 7 "Script: "; print_cl 2 "up to date.\n"
fi
