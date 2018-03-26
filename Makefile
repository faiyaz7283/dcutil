#-------------------------------------------------------------------------------------------------[ Includes ]----------
include ./libs/variables.mk
include ./libs/printing-functions.mk
include ./libs/helper-functions.mk
include ./libs/docker-functions.mk

#--------------------------------------------------------------------------------------------[ Phony targets ]----------
.PHONY : $(all_targets)

#-------------------------------------------------------------------------------------------[ Helper targets ]----------
show_commands commands targets:
	@$(call print_color, 3, "All available commands (targets)."); \
	$(call print_command, Build, $(build_ts)); \
	$(call print_command, Setup, $(setup_ts)); \
	$(call print_command, Project, $(project_ts)); \
	$(call print_command, Docker, $(docker_ts)); \
	$(call print_command, Helper, $(helper_ts))

show_projects projects : isset_env
	@$(call get_dcutil_projects); \
	total="$${#projects[@]}"; \
	(( "$$total" != 0 )) && color=2 || color=1; \
	$(call print_dual_color, 7, "Total DCUTIL projects:", $$color, " $${total}"); \
	if (( "$$total" != 0 )); then \
		for i in $$(seq 0 $$(( "$$total" - 1 )) ); do \
			index="$$(( $$i + 1 ))"; \
			$(call print_triple_color, 7, "$$index", 3, " => ", 2, "$${projects[$$i]}") ;  \
		done; \
	fi

version :
	@$(call version)

help man :
	@$(call help)

rm_vars : check_not_root isset_p_param isset_env
	@$(call print_running_target); \
	$(call to_upper, p, $(p)); \
	if grep -Fq "$${p}" .env; then \
		$(call print_color, 3, "Are you sure? All $(p) related variables from the .env file will be removed ?"); \
		select choice in "Yes" "No"; do \
			case $$choice in \
				Yes ) $(call remove_matching_line, $${p}_, .env); \
					  $(call print_target_success, "All $(p) related variables have been removed from .env file."); \
					  break;; \
				No )  exit;; \
				* ) echo "Please enter 1 for Yes or 2 for No.";; \
			esac; \
		done; \
	else \
		$(call print_color, 1, "Sorry$(,) there's no $(p) related variables found on .env file."); \
	fi; \
	$(call print_completed_target)

#---------------------------------------------------------------------------------------[ Validation targets ]----------
check_not_root :
ifeq ($(shell id -u),0)
	@$(call print_color, 1, "Please do not use sudo or run as root"); \
	$(call print_failed_target); \
	exit 1
endif

isset_p_param :
ifndef p
	@$(call print_color, 1, "Missing project parameter."); \
	$(call print_failed_target); \
	exit 1
else
	@$(MAKE) isset_valid_project_name
endif

isset_valid_project_name :
	@$(call is_valid_project_name, $(p)); \
	if [ "$$valid" == false ]; then \
		$(call print_color, 1, "Project name contains invalid character. Use only letters$(,) numbers and underscore."); \
		exit 1; \
	fi

is_wd_exist :
	@$(call get_dcutil_project_working_dir); \
	if [ ! -d "$$wd" ]; then \
		$(call print_color, 1, "Working directory does not exist."); \
		$(call print_failed_target); \
		exit 1; \
	fi

isset_env :
ifeq (,$(wildcard .env))
	@$(call print_color, 1, "Missing .env file. Please copy the .env.example file to start or add one manually."); \
	$(call print_failed_target); \
	exit 1
endif

isset_valid_cf : check_not_root isset_p_param isset_env
	@$(call get_dcutil_project_docker_compose_files); \
	if [ "$$dcfs" ]; then \
		invalid=(); \
		missing=(); \
		for i in $${!dcfs[@]}; do \
			dcf=$${dcfs[$$i]}; \
			if [ -f "$$dcf" ]; then \
				if ! grep -q 'services:' "$$dcf"; then \
					$(call print_color, 1, "File "$$dcf" is invalid."); \
					invalid+=("$$dcf"); \
				fi; \
			else \
				$(call print_color, 1, "File "$$dcf" could not be located."); \
				missing+=("$$dcf"); \
			fi; \
		done; \
		if (( "$${#invalid[@]}" > 0 )) || (( "$${#missing[@]}" > 0 )); then \
			$(call print_failed_target); \
			exit 1; \
		fi; \
	fi

#--------------------------------------------------------------------------------------------[ Setup targets ]----------
set_project : check_not_root isset_p_param
	@$(call print_running_target); \
	if [ "$$repo" ]; then \
		$(MAKE) set_git_code_project; \
	else \
		if [ "$$dir_empty" == true -o "$$project_exist" == false ]; then \
			$(call get_dcutil_project_working_dir); \
			$(call sanitize_dir, wd, $$wd); \
			cd $$wd; \
			if [ -z "$$repo" ]; then \
				$(call print_color, 3, "Enter your git repository url: "); \
				read repo; \
			fi; \
			$(call print_target_info, "Cloning project from $$repo."); \
			if git clone $$repo ./$(p) > /dev/null 2>&1; then \
				$(call print_target_success, "Project $(p) cloned."); \
			else \
				$(call print_target_error, "Failed to clone $(p) project from the provided repository."); \
			fi; \
		fi; \
	fi; \
	$(call print_completed_target)

#--------------------------------------------------------------------------------------------[ Build targets ]----------
build : check_not_root isset_p_param isset_env isset_valid_cf
	@$(call print_running_target); \
	$(call get_dcutil_project_working_dir); \
	$(call get_dcutil_project_docker_compose_files); \
	$(MAKE) docker_up_detailed; \
	$(MAKE) pkg_mgmt; \
	$(MAKE) migration; \
	$(call print_completed_target)

build_project : check_not_root isset_p_param isset_env
	@$(call print_running_target); \
	$(call get_dcutil_project_working_dir); \
	p_dir=$${wd}/$(p); \
	if [ -d "$$p_dir" ]; then \
		if [ "$$(ls -A $$p_dir)" ]; then \
			$(call print_target_success, "Project directory exist."); \
			cwd=$$(pwd); \
			cd $$p_dir; \
			if git rev-parse --git-dir > /dev/null 2>&1; then \
				$(call print_target_general, "Its a git project$(,) running git pull."); \
				git fetch --all; git pull; \
			else \
				$(call print_target_error, "Not a git repo."); \
			fi; \
		else \
			$(call print_target_error, "Directory exist but empty."); \
			$(MAKE) set_code_project dir_empty=true; \
		fi; \
	else \
		$(call print_target_error, "Project does not exist."); \
		$(MAKE) set_code_project project_exist=false; \
	fi; \
	$(call print_completed_target)

build_docker : check_not_root isset_p_param isset_env isset_valid_cf
	@$(call print_running_target); \
	$(MAKE) docker_up_detailed; \
	$(call print_completed_target)

#------------------------------------------------------------------------------------------[ Project targets ]----------
pkg_mgmt : check_not_root isset_p_param isset_env
	@$(call override)

migration : check_not_root isset_p_param isset_env
	@$(call override)

#-----------------------------------------------------------------------------------[ Custom project targets ]----------
# Custom project targets points to the cutom project makefile. Users can call any custom targets prepending target name
# with double underscores.
#-----------------------------------------------------------------------------------------------------------------------
__% : isset_p_param isset_env
	@target=$@; \
	target=$${target#__}; \
	$(call override, $$target); \
	if [ -z "$$override" ]; then \
		$(call print_color, 1, "Cannot find target $$target."); \
		exit 1; \
	fi

#-------------------------------------------------------------------------------------------[ Docker targets ]----------
# For docker_login, docker_cmd and docker_workstation use the parameters below:
# cmd = Pass the command, or a group of commands (grouped commands must be enclosed in quotes).
# cnt = The service container name.
# cnt_user = The user to enter the container.
# cnt_shell = The container shell.
#-----------------------------------------------------------------------------------------------------------------------
docker_% : check_not_root isset_p_param isset_env isset_valid_cf
	@$(call override); \
	if [ -z "$$override" ]; then \
		$(call print_running_target); \
		$(call extract_dcfs_for_docker_compose); \
		$(call $@); \
		$(call print_completed_target); \
	fi
