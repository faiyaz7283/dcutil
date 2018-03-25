#---------------------------------------------------------------------------------------[ Printing functions ]----------
# Print into terminal with choice of color [1-7].
# 0 – Black.
# 1 – Red.
# 2 – Green.
# 3 – Yellow.
# 4 – Blue.
# 5 – Magenta.
# 6 – Cyan.
# 7 – White.
#-----------------------------------------------------------------------------------------------------------------------
define color_text
	tput setaf $(1); \
	printf $(2); \
	tput sgr0
endef

# Adds color to text and new line at the end
define print_color
	$(call color_text, $(1), $(2)'\n')
endef

# Print in dual colored text and new line at the end
define print_dual_color
	$(call color_text, $(1), $(2)); \
    	$(call color_text, $(3), $(4)'\n')
endef

# Print in triple colored text and new line at the end
define print_triple_color
	$(call color_text, $(1), $(2)); \
	$(call color_text, $(3), $(4)); \
	$(call color_text, $(5), $(6)'\n')
endef

# Container enter printing
# $1 = command
# $2 = container
# $3 = shell
# $4 = user
define print_container_enter
	if [ "$(silent)" = "false" ]; then \
		$(call color_text, 6, "Command: "); \
		$(call color_text, 7,"$(1)\n"); \
		$(call color_text, 6, "Container: "); \
		$(call color_text, 7,"$(2)\n"); \
		$(call color_text, 6, "Shell: "); \
		$(call color_text, 7,"$(3)\n"); \
		$(call color_text, 6, "User: "); \
		$(call color_text, 7,"$(4)\n"); \
		$(call color_text, 6, "Time: "); \
		$(call color_text, 7,"$$(date '+%Y-%m-%d %H:%M:%S')\n\n"); \
	fi
endef

# Container exit printing
define print_container_exit
	if [ "$(silent)" == "false" ]; then \
		$(call color_text, 8, "\nExit; $$(date '+%Y-%m-%d %H:%M:%S')\n"); \
	fi
endef

# Running target printing
define print_running_target
	if [ "$(silent)" == "false" ]; then \
		$(call trim, custom, $(1)); \
		custom=$${custom:-$@}; \
		$(call print_dual_color, 2, "running... ", 7, "$${custom}"); \
	fi
endef

# Target completed printing
define print_completed_target
	if [ "$(silent)" == "false" ]; then \
		$(call trim, custom, $(1)); \
		custom=$${custom:-$@}; \
		$(call print_triple_color, 2, "√ ", 7, "$${custom} ", 2, "done"); \
	fi
endef

# Target failed printing
define print_failed_target
	if [ "$(silent)" == "false" ]; then \
		$(call trim, custom, $(1)); \
		custom=$${custom:-$@}; \
		$(call print_triple_color, 1, "X ", 7, "$${custom} ", 1, "failed"); \
	fi
endef

# info printing
define print_target_info
	if [ "$(silent)" == "false" ]; then \
		$(call print_dual_color, 6, " • ", 7, $(1)); \
	fi
endef

# general printing
define print_target_general
	if [ "$(silent)" == "false" ]; then \
		$(call print_dual_color, 7, " • ", 7, $(1)); \
	fi
endef

# success printing
define print_target_success
	if [ "$(silent)" == "false" ]; then \
		$(call print_dual_color, 2, " • ", 7, $(1)); \
	fi
endef

# error printing
define print_target_error
	if [ "$(silent)" == "false" ]; then \
		$(call print_dual_color, 1, " • ", 7, $(1)); \
	fi
endef

# Print command for a specific type
define print_command
	$(call trim, name, $(1)); \
	$(call trim, commands, $(2)); \
	commands="$${commands// /\\n - }"; \
	$(call print_dual_color, 7, "\n$${name} specific commands: \n", 2, " - $${commands}")
endef

# Print version
define version
	version=$$(git describe --always --tags); \
	sha1=$$(git rev-parse HEAD); \
	release_date=$$(git log -1 --format=%ai $$version); \
	b=$$(tput bold); \
	n=$$(tput sgr0); \
	line=$$(printf "=%.0s" {1..25}); \
	printf "\
		$${b}DCUTIL$${n}\n\
		- Version: $${b}$${version}$${n}\n\
		- Released: $${b}$${release_date:0:10}$${n}\n\
		- SHA-1: $${b}$${sha1}$${n}\
	\n"
endef

# Print help
define help
	clear; \
	b=$$(tput bold); \
    n=$$(tput sgr0); \
	printf "\
		DCUTIL(1)\t\tGeneral Commands Manual\n\n\
		$${b}NAME$${n}\n \
		\tdcutil -- A docker-compose utility for php projects.\n\n\
		$${b}SYNOPSIS$${n}\n\
		\tdcutil [ options ] [ parameters ] <target>\n\n\
		$${b}DESCRIPTION$${n}\n\
		\tA utility program for php projects to run with docker-compose. The main objective of using DCUTIL - is to make \n\
		\trunning of php projects on docker cnts a cinch. It simply helps automate helpful functions, which in \n\
		\totherwise most would do manually.\n\n\
		$${b}OPTIONS$${n}\n\
		\tOption must be the first argument. Only one option should be passed at a time. If more than one option is \n\
		\tpresent, only the first option will be used. Options cannot be combined with parameters.\n\n\
		\t-u, --update\tUpdate the dcutil program and the git project.\n\
		\t-r, --remove\tRemove the dcutil program and the git project.\n\
		\t-h, --help\n\
		\t    --man\tDisplay this help manual.\n\n\
		$${b}PARAMETERS$${n}\n\
		\tThere is only one required parameter 'p' (project). DCUTIL needs the name of the project to work. Optional \n\
		\tparameters can be set to bypass certain functionalities, or override .env variables etc.\n\n\
		\t$${b}Required:$${n}\n\
		\tp\t\tThe name of the project.\n\
		\t\t\tProject name can also be set with just the name of the project by itself without the p=project convetion. \n\
		\t\t\tIf 1 or more projects already set in .env file, then you can also use the key instead of the project name. \n\
		\t\t\tFor example, let say in your .env file you have PROJECTS=apple:orange:banana. In order to run the apple \n\
		\t\t\tproject, you can simply use the key 1, and for orange use 2, and for banana use 3.\n\n\
		\t$${b}Optional$${n}\n\
		\tdocker\t\tDefaults to false. If set to true, will bypass prompt and force run build docker.\n\
		\trepo\t\tIf set with git repository url, will bypass prompt and force git repo cloning.\n\
		\tcomposer\tIf set with a value of 'install', 'update', or 'nothing', will bypass prompt and force run \n\
		\t\t        composer with given choice.\n\
		\tsilent\t\tBy default, dcutil is verbose and this value is false. If set to true, dcutil will silent its \n\
		\t\t        internal verbosity.\n\
		\tcnt\t\tName of the targeted container.\n\
		\tcnt_shell\tDefault value is 'sh'. Can be overridden with a valid available container shell name.\n\
		\tcnt_user\tDefault value is 'root'. Can be overridden with a valid available container user name.\n\n\
		$${b}EXAMPLE USAGES$${n}\n\
		\tUsing options:\n\
		\t$${b}To check the DCUTIL version, use either -v or --version.$${n}\n\
		\t$$ dcutil -v\n\
		\t$$ dcutil --version\n\n\
		\t$${b}To update DCUTIL, use either -u or --update.$${n}\n\
        \t$$ dcutil -u\n\
        \t$$ dcutil --update\n\n\
        \t$${b}To remove DCUTIL from your machine, use either -r or --remove.$${n}\n\
		\t$$ dcutil -r\n\
		\t$$ dcutil --remove\n\n\
		\t$${b}To get this help manual, use either -h, --help or --man.$${n}\n\
		\t$$ dcutil -h\n\
		\t$$ dcutil --help\n\
		\t$$ dcutil --man\n\n\
		\tUsing parameters:\n\
		\t$${b}Explicitely using the parameter p to set a project name called apple.$${n}\n\
		\t$$ dcutil p=apple\n\n\
		\t$${b}Using only the project's name apple directly.$${n}\n\
		\t$$ dcutil apple\n\n\
		\t$${b}Using the index for apple project. Let assume file .env has the following set PROJECTS=orange:apple.$${n}\n\
		\tKeep in mind, you can only use index, if project is already set in .env file, otherwise you will get an error.\n\
		\t$$ dcutil 2\n\n\
		\t$${b}Logging into project apple's workstation.$${n}\n\
		\tAll targets starting with docker_ can be overridden on your custom project make file.\n\
		\t$$ dcutil apple docker_workstation\n\n\
		\t$${b}Checking project apple's docker status.$${n}\n\
		\t$$ dcutil apple docker_ps\n\n\
		For more info and full usage details, please visit the github page at https://github.com/faiyaz7283/dcutil.\n\
	" | less -R
endef