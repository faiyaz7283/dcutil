#-----------------------------------------------------------------------------------[ Docker-Compose targets ]----------
# For dc_login and dc_cmd use the parameters below:
# cnt = The service container name.
# cnt_user = The user to enter the container.
# cnt_shell = The container shell.
# cmd = Pass the command, or a group of commands (grouped commands must be enclosed in quotes).
#-----------------------------------------------------------------------------------------------------------------------
dc_intro= $(call print_running_target); $(call extract_dcfs_for_docker_compose)

dc_% :
	@dc_cmd=$@; \
	dc_cmd=$${dc_cmd#dc_}; \
	$(dc_intro); \
	$(dc_compose) $${dc_cmd} $${args}; \
	$(call print_completed_target)

# Check projects docker containers statuses
dc_ps :
	 @$(call dc_intro); \
	 if [ "$${args}" ]; then \
		$(dc_compose) ps $${args}; \
	 else \
	 	$(dc_compose) ps; \
	 fi; \
	 $(call print_completed_target)

# Bring up the external dependencies
dc_up_dependencies :
	@$(call print_running_target); \
	$(call to_upper, project_dependencies_var, $(p)_SERVICE_DEPENDENCIES); \
	dependencies=($$(echo $${!project_dependencies_var//:/ })); \
	for i in "$${dependencies[@]}"; do \
		items=($$(echo $${i//|/ })); \
		project=$${items[0]}; \
		dcfile=$${dcutil_libs}/docker-compose/$${project}.yml; \
		$(call check_dcutil_project_exist, $$project); \
		if [ -f "$$dcfile" -a "$$exist" == "true" ]; then \
			$(call trim, items, "$${items[@]:1}"); \
			[ "$${items[1]}" ] && services="$${items[@]:1}"; \
			$(call print_target_info, "Running docker-compose up on project \"$${project}\" with service(s): $${services:-all available}"); \
			docker-compose -f $${dcfile} -p $${project} up -d --build $${services:-}; \
		fi; \
	done; \
	$(call print_completed_target)

# Bring up docker containers and prints out detailed info bout current cnts status and comeplete execution time
dc_up : dc_up_dependencies
	@$(call dc_intro); \
	if [ "$${args}" ]; then \
		$(dc_compose) up $${args}; \
	else \
		$(dc_compose) up -d --build; \
		$(self_make) dc_ps; \
	fi; \
	$(call print_completed_target)

# Bring down docker containers.
dc_down :
	@$(call dc_intro); \
	[ -z "$${args}" ] && args="--remove-orphans"; \
	$(dc_compose) down $${args}; \
	$(call print_completed_target)

# Stops and starts containers
dc_restart :
	@$(call dc_intro); \
	$(dc_compose) stop $${args}; \
	$(dc_compose) start $${args}; \
	$(call print_completed_target)
# Enter a docker continer with the following parameters
# cnt (REQUIRED) - Refers to the cnts service name given in the project's docker-compose yml file.
# cnt_shell (NOT-REQUIRED) - Defaults to sh. Can also be set in .env file using {PROJECT}_WORKSTATION_SHELL variable.
# cnt_user (NOT-REQUIRED) - Defaults to root. Can also be set in .env file using {PROJECT}_WORKSTATION_USER variable.
dc_login :
	@$(call dc_intro); \
	$(call print_container_enter, login, $(cnt), $(cnt_shell), $(cnt_user)); \
	$(dc_compose) exec --user=$(cnt_user) $(cnt) $(cnt_shell); \
	$(call print_container_exit); \
	$(call print_completed_target)


# Run a command in a docker continer with the following parameters
# cmd (REQUIRED) - The command or group of commands (enclosed in quotes) that needs to be performed inside the cnt.
# cnt (REQUIRED) - Refers to a cnts service name given in the project's docker-compose yml file.
# cnt_shell (NOT-REQUIRED) - Defaults to sh. Can also be set in .env file using {PROJECT}_WORKSTATION_SHELL variable.
# cnt_user (NOT-REQUIRED) - Defaults to root. Can also be set in .env file using {PROJECT}_WORKSTATION_USER variable.
dc_cmd :
	@$(call dc_intro); \
	$(call print_container_enter, $(cmd), $(cnt), $(cnt_shell), $(cnt_user)); \
	$(dc_compose) exec --user=$(cnt_user) $(cnt) $(cnt_shell) -l -c "$(cmd)"; \
	$(call print_container_exit); \
	$(call print_completed_target)