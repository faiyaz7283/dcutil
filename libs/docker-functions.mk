#-----------------------------------------------------------------------------------------[ Docker functions ]----------
# Check projects docker cnt statuses
define docker_ps
	$(docker_compose) ps
endef

# Check proejcts docker images
define docker_images
	$(docker_compose) images
endef

# Bring up docker cnts.
define docker_up
	$(docker_compose) up -d --build
endef

# Bring up docker cnts and prints out detailed info bout current cnts status and comeplete execution time
define docker_up_detailed
	/usr/bin/time -p $(call docker_up); \
	printf "\n"; $(call docker_ps); printf "\n"
endef

# Bring down docker cnts.
define docker_down
	$(docker_compose) down --remove-orphans
endef

# Start docker cnts.
define docker_start
	$(docker_compose) start
endef

# Stop docker cnts.
define docker_stop
	$(docker_compose) stop
endef

# Enter a docker continer with the following parameters
# cnt (REQUIRED) - Refers to the cnts service name given in the project's docker-compose yml file.
# cnt_shell (NOT-REQUIRED) - Defaults to sh. Can also be set in .env file using {PROJECT}_WORKSTATION_SHELL variable.
# cnt_user (NOT-REQUIRED) - Defaults to root. Can also be set in .env file using {PROJECT}_WORKSTATION_USER variable.
define docker_login
	$(call print_container_enter, login, $(cnt), $(cnt_shell), $(cnt_user)); \
	$(docker_compose) exec --user=$(cnt_user) $(cnt) $(cnt_shell); \
	$(call print_container_exit)
endef

# Run a command in a docker continer with the following parameters
# cmd (REQUIRED) - The command or group of commands (enclosed in quotes) that needs to be performed inside the cnt.
# cnt (REQUIRED) - Refers to a cnts service name given in the project's docker-compose yml file.
# cnt_shell (NOT-REQUIRED) - Defaults to sh. Can also be set in .env file using {PROJECT}_WORKSTATION_SHELL variable.
# cnt_user (NOT-REQUIRED) - Defaults to root. Can also be set in .env file using {PROJECT}_WORKSTATION_USER variable.
define docker_cmd
	$(call print_container_enter, $(cmd), $(cnt), $(cnt_shell), $(cnt_user)); \
	$(docker_compose) exec --user=$(cnt_user) $(cnt) $(cnt_shell) -l -c "$(cmd)"; \
	$(call print_container_exit)
endef

# Enter or run command inside docker workstation cnt with cmd={command}
# cmd (NOT-REQUIRED) - The command or group of commands that needs to be performed inside the cnt or defaults to login.
# cnt_shell (NOT-REQUIRED) - Defaults to sh. Can also be set in .env file using {PROJECT}_WORKSTATION_SHELL variable.
# cnt_user (NOT-REQUIRED) - Defaults to root. Can also be set in .env file using {PROJECT}_WORKSTATION_USER variable.
define docker_workstation
	$(call export_env); \
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
		$(docker_compose) exec --user=$${cnt_user:-$$c_user} workstation $${cnt_shell:-$$c_shell} -l -c "$(cmd)"; \
	else \
		$(docker_compose) exec --user=$${cnt_user:-$$c_user} workstation $${cnt_shell:-$$c_shell}; \
	fi; \
	$(call print_container_exit)
endef