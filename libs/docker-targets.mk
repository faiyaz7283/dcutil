#-----------------------------------------------------------------------------------[ Docker-Compose targets ]----------
# For dc_login, dc_cmd and dc_workstation use the parameters below:
# cmd = Pass the command, or a group of commands (grouped commands must be enclosed in quotes).
# cnt = The service container name.
# cnt_user = The user to enter the container.
# cnt_shell = The container shell.
#-----------------------------------------------------------------------------------------------------------------------
dc_start_wrap = $(call override); $(call print_running_target); $(call extract_dcfs_for_docker_compose)

# Start docker containers from docker compose file.
dc_start :
	@$(call dc_start_wrap); \
	$(dc_compose) start; \
	$(call print_completed_target)


# Stop all docker-compose related running containers.
dc_stop :
	@$(call dc_start_wrap); \
	$(dc_compose) stop; \
	$(call print_completed_target)


# Check projects docker containers statuses
dc_ps :
	 @$(call dc_start_wrap); \
	 $(dc_compose) ps; \
	 $(call print_completed_target)


# Bring up docker containers.
dc_up :
	@$(call dc_start_wrap); \
	$(dc_compose) up -d --build; \
    $(call print_completed_target)


# Bring up docker containers and prints out detailed info bout current cnts status and comeplete execution time
dc_up_detailed :
	@$(call dc_start_wrap); \
	/usr/bin/time -p $(self_make) dc_up; \
	printf "\n"; $(self_make) dc_ps; printf "\n"; \
	$(call print_completed_target)


# Bring down docker containers.
dc_down :
	@$(call dc_start_wrap); \
	$(dc_compose) down --remove-orphans; \
	$(call print_completed_target)


# Enter a docker continer with the following parameters
# cnt (REQUIRED) - Refers to the cnts service name given in the project's docker-compose yml file.
# cnt_shell (NOT-REQUIRED) - Defaults to sh. Can also be set in .env file using {PROJECT}_WORKSTATION_SHELL variable.
# cnt_user (NOT-REQUIRED) - Defaults to root. Can also be set in .env file using {PROJECT}_WORKSTATION_USER variable.
dc_login :
	@$(call dc_start_wrap); \
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
	@$(call dc_start_wrap); \
	$(call print_container_enter, $(cmd), $(cnt), $(cnt_shell), $(cnt_user)); \
	$(dc_compose) exec --user=$(cnt_user) $(cnt) $(cnt_shell) -l -c "$(cmd)"; \
	$(call print_container_exit); \
	$(call print_completed_target)


# Enter or run command inside docker workstation cnt with cmd={command}
# cmd (NOT-REQUIRED) - The command or group of commands that needs to be performed inside the cnt or defaults to login.
# cnt_shell (NOT-REQUIRED) - Defaults to sh. Can also be set in .env file using {PROJECT}_WORKSTATION_SHELL variable.
# cnt_user (NOT-REQUIRED) - Defaults to root. Can also be set in .env file using {PROJECT}_WORKSTATION_USER variable.
dc_workstation :
	@$(call dc_start_wrap); \
	$(call to_upper, pwuser, $(p)_WORKSTATION_USER); \
	$(call to_upper, pwshell, $(p)_WORKSTATION_SHELL); \
	if [ "$${!pwuser}" ]; then \
		c_user=$${!pwuser}; \
	else \
		[ "$${WORKSTATION_USER}" ] && c_user=$${WORKSTATION_USER} || c_user=root; \
	fi; \
	if [ "$${!pwshell}" ]; then \
		c_shell=$${!pwshell}; \
	else \
		[ "$${WORKSTATION_SHELL}" ] && c_shell=$${WORKSTATION_SHELL} || c_shell=sh; \
	fi; \
	$(call print_container_enter, $${cmd:-login}, workstation, $${cnt_shell:-$$c_shell}, $${cnt_user:-$$c_user}); \
	if [ "$${cmd}" -a "$${cmd}" != "login" ]; then \
		$(dc_compose) exec --user=$${cnt_user:-$$c_user} workstation $${cnt_shell:-$$c_shell} -l -c "$(cmd)"; \
	else \
		$(dc_compose) exec --user=$${cnt_user:-$$c_user} workstation $${cnt_shell:-$$c_shell}; \
	fi; \
	$(call print_container_exit); \
	$(call print_completed_target)

# Check proejcts docker images
dc_images :
	@$(call dc_start_wrap); \
	$(dc_compose) images; \
	$(call print_completed_target)