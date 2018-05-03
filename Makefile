#--------------------------------------------------------------------------------------------[ Includes Vars ]----------
include libs/vars.mk
include libs/printing-vars.mk
include libs/helper-vars.mk
include libs/docker-targets.mk

#--------------------------------------------------------------------------------------------[ Phony targets ]----------
.PHONY : $(all_ts)

#-------------------------------------------------------------------------------------------[ Helper targets ]----------
show_commands commands targets:
	@$(call print_color, 3, "All available commands (targets)."); \
	if [ "$(p)" ]; then \
		$(call get_custom_project_makefile); \
		if [ -f "$$pmf" ]; then \
			custom_ts=($$($(MAKE) -f $$pmf -I $$(dirname $${pmf}) list_ts)); \
			custom_ts=($${custom_ts[@]}); \
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

isset_env :
	@if [ ! -f "$${dcutil_libs}/.env" ]; then \
		$(call print_color, 1, "Missing .env file. Please copy the .env.example file to start or add one manually."); \
		$(call print_failed_target); \
		exit 1; \
	fi

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
	$(call get_code_projects); \
	$(call get_custom_project_makefile) && dirname=$$(dirname $${pmf}); \
	if [ -f "$${pmf}" ] && grep -Eqr ".*before_tasks.*:.*" $${pmf}; then \
		$(MAKE) -f $${pmf} -I $${dirname} before_tasks; \
	fi; \
	for code_project in $${code_projects[@]}; do \
		$(call check_code_project_exist, "$${code_project}"); \
		if [ "$$exist" == "true" ]; then \
			$(MAKE) -f $${pmf} -I $$dirname "$${code_project}_tasks"; \
		else \
			$(call print_target_error, "Code project '$${code_project}' does not exist."); \
		fi; \
	done; \
	if [ -f "$${pmf}" ] && grep -Eqr ".*after_tasks.*:.*" $${pmf}; then \
		$(MAKE) -f $${pmf} -I $${dirname} after_tasks; \
	fi; \
	$(call print_completed_target)

#-----------------------------------------------------------------------------------[ Custom project targets ]----------
# Custom project targets points to the cutom project makefile. Users can call any custom targets prepending target name
# with double underscores.
#-----------------------------------------------------------------------------------------------------------------------
__% : check_not_root isset_valid_p isset_env
	@target=$@; \
	target=$${target#__}; \
	$(call override, $$target); \
	$(call print_color, 1, "Cannot find target $${target}.") && exit 1