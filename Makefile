#--------------------------------------------------------------------------------------------[ Includes Vars ]----------
include libs/vars.mk
include libs/printing-vars.mk
include libs/helper-vars.mk

#--------------------------------------------------------------------------------------------[ Phony targets ]----------
.PHONY : $(all_ts)

#-------------------------------------------------------------------------------------------[ Helper targets ]----------
show_commands commands targets:
	@$(call print_color, 3, "All available commands (targets)."); \
	if [ "$(p)" ]; then \
		$(call get_custom_project_makefile); \
		if [ -f "$$pmf" ]; then \
			custom_ts=($$($(MAKE) -f $$pmf -I $$(dirname $${pmf}) list_ts)); \
			custom_ts=($${custom_ts[@]/list_ts}); \
			(( $${#custom_ts[@]} > 0 )) && $(call print_command, Project $(p), $${custom_ts[@]}); \
		fi; \
	fi; \
	$(call print_command, Build, $(build_ts)); \
	$(call print_command, 'Docker Compose', $(dc_ts)); \
	$(call print_command, Helper, $(helper_ts))

show_projects projects : isset_env
	@$(call get_dcutil_projects); \
	total="$${#projects[@]}"; \
	(( "$$total" != 0 )) && color=2 || color=1; \
	$(call print_dual_color, 7, "Total DCUTIL projects:", $$color, " $${total}"); \
	if (( "$$total" != 0 )); then \
		for i in $$(seq 0 $$(( $${total} - 1 )) ); do \
			index="$$(( $$i + 1 ))"; \
			$(call print_triple_color, 7, "$$index", 3, " => ", 2, "$${projects[$$i]}") ;  \
		done; \
	fi

rm_vars : check_not_root isset_p isset_env
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

isset_p :
ifndef p
	@$(call print_color, 1, "Missing project parameter."); \
	$(call print_failed_target); \
	exit 1
endif

isset_valid_p : isset_p
	@$(call is_valid_project_name, $(p)); \
	if [ "$$valid" == false ]; then \
		$(call print_color, 1, "Project name contains invalid character. Use only letters$(,) numbers and underscore."); \
		exit 1; \
	fi

is_code_project_exist : isset_valid_p isset_env
	@$(call get_dcutil_project_working_dir); \
	p_dir=$${wd}/$(p); \
	if [ -d "$$p_dir" ]; then \
		if [ ! "$$(ls -A $$p_dir)" ]; then \
			$(call print_color, 1, "Code project directory is empty."); \
			$(call print_failed_target); \
			exit 1; \
		fi; \
	else \
		$(call print_color, 1, "Code project directory does not exist."); \
		$(call print_failed_target); \
		exit 1; \
	fi

isset_env :
ifeq (,$(wildcard .env))
	@$(call print_color, 1, "Missing .env file. Please copy the .env.example file to start or add one manually."); \
	$(call print_failed_target); \
	exit 1
endif

isset_valid_cf : check_not_root isset_valid_p isset_env
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

#--------------------------------------------------------------------------------------------[ Build targets ]----------
build : check_not_root isset_valid_p isset_env isset_valid_cf
	@$(call print_running_target); \
	$(call get_dcutil_project_working_dir); \
	$(call get_dcutil_project_docker_compose_files); \
	$(self_make) dc_up_detailed; \
	$(self_make) prj_mgmt; \
	$(call print_completed_target)

#-----------------------------------------------------------------------------------[ Docker-Compose targets ]----------
include libs/docker-targets.mk

#-----------------------------------------------------------------------------------[ Custom project targets ]----------
# Custom project targets points to the cutom project makefile. Users can call any custom targets prepending target name
# with double underscores.
#-----------------------------------------------------------------------------------------------------------------------
__% : check_not_root isset_valid_p isset_env
	@target=$@; \
	target=$${target#__}; \
	$(call override, $$target); \
	$(call print_color, 1, "Cannot find target $$taclearqrget."); \
	exit 1

#---------------------------------------------------------------------------[ Custom project wrapper targets ]----------
prj_mgmt : check_not_root isset_valid_p isset_env
	@$(call override)