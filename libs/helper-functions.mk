#-----------------------------------------------------------------------------------------[ Helper functions ]----------
# Export .env variables
define export_env
	[ -f ".env" ] && export $$(cat .env | grep -v ^\# | xargs)
endef

# Convert string to upper
define to_upper
	$(1)=$$(echo $(2) | tr '[:lower:]' '[:upper:]')
endef

# Convert string to lower
define to_lower
	$(1)=$$(echo $(2) | tr '[:upper:]' '[:lower:]')
endef

# Convert tilda to full home path, and remove trailing slashes and trim white spaces
define sanitize_dir
	value="$(2)"; \
	value=$${value/\~/$$HOME}; \
	value=$${value%/}; \
	$(call trim, $(1), $$value)
endef

# Trim white spaces
define trim
	value="$(2)"; \
	$(1)=$$(echo $${value%/} | xargs)
endef

# Set a var
define var
	$(call trim, value, $(2)); \
	$(1)="$$value"
endef

# Search for string, replace with string in the given file
define find_replace
	if [ "$(4)" ]; then \
		$(call trim, dlm, $(4)); \
	else \
		dlm=#; \
	fi; \
	$(call trim, find, $(1)); \
	$(call trim, replace, $(2)); \
	$(call trim, file, $(3)); \
	sed -i.bak -e "s$${dlm}$${find}$${dlm}$${replace}$${dlm}g" $$file && rm -f $${file}.bak
endef

# Replace or update
define replace_or_update
	$(call trim, var_name, $(1)); \
	var_name=$${var_name%'%'}; \
	var_name=$${var_name#'%'}; \
    $(call find_replace, $(1), $(2), $(3), $${4:-#}); \
	if [ "$${!var_name}" ] && [ -f "$${file}.backup" ]; then \
		$(call remove_matching_line, $$var_name, $${file}.backup); \
	fi
endef

# Search for matching string, and remove the entire line
define remove_matching_line
	$(call trim, find, $(1)); \
	$(call trim, file, $(2)); \
	sed -i.bak -e "/$${find}/d" $$file && rm -f $${file}.bak
endef

# Determines users private IP only if Darwin/Mac or GNU/Linux.
define get_ip
	if [ "$$(uname)" == "Darwin" ]; then \
		ip=$$(ipconfig getifaddr en0); \
	elif [ "$$(expr substr $$(uname -s) 1 5)" == "Linux" ]; then \
		ip=$$(hostname -I); \
	elif [ "$$(expr substr $$(uname -s) 1 10)" == "MINGW32_NT" ] || [ "$$(expr substr $$(uname -s) 1 10)" == "MINGW64_NT" ]; then \
		ip=''; \
	fi
endef

# Override a target
define override
	$(call trim, target, $(1)); \
	target=$${target:-$@}; \
	$(call get_custom_project_makefile); \
 	if [ -f "$${pmf}" ] && grep -q "^$${target}\s*:" $${pmf}; then \
 		makefilename="$$(basename $${pmf})"; \
 		$(call print_running_target, '$${makefilename} » $$target'); \
 		$(MAKE) -f $${pmf} $$target; \
 		$(call print_completed_target, '$${makefilename} » $$target'); \
 		exit 0; \
 	fi
endef

# Get this project's working Directory:
# First look for {PROJECT}_WORKING_DIR and then HOST_WORKING_DIR value in .env file, if neither is set return error
define get_dcutil_project_working_dir
	$(call to_upper, wd, $(p)_WORKING_DIR); \
	if [ "$${!wd}" ]; then \
		$(call sanitize_dir, wd, $${!wd}); \
	elif [ "$${HOST_WORKING_DIR}" ]; then \
		$(call sanitize_dir, wd, $${HOST_WORKING_DIR}); \
	else \
		$(call print_color, 1, "Missing working directory. Unable to substitute a value from .env file."); \
		$(call to_upper, p, $(p)); \
		$(call print_color, 3, "[ HINT ] Please set $${p}_WORKING_DIR or HOST_WORKING_DIR in your .env file."); \
		exit 1; \
	fi
endef

# Get this project's docker compose file or return error
define get_dcutil_project_docker_compose_files
	pld=$$DCUTIL_LIBS_DIR; \
	dcfs_dir="$${pld}/docker-compose"; \
	if [ "$$pld" -a -d "$$dcfs_dir" ]; then \
		$(call to_upper, dcfs, $(p)_DOCKER_COMPOSE_FILES); \
		if [ "$${!dcfs}" ]; then \
			dcfs=(`echo "$${dcfs_dir}/$${!dcfs//:/ $$dcfs_dir/}"`); \
		fi; \
	fi
endef

# Extract docker compose file names and set with -f flag for multiple files
define extract_dcfs_for_docker_compose
	$(call get_dcutil_project_docker_compose_files); \
	if [ "$$dcfs" ]; then \
		$(call var, docker_compose_files, `echo $${dcfs//:/ -f }`); \
	fi
endef

# Get this project's make file
define get_custom_project_makefile
	pld=$$DCUTIL_LIBS_DIR; \
	mkfs_dir="$${pld}/makefiles"; \
	if [ "$$pld" -a -d "$$mkfs_dir" ]; then \
		$(call to_upper, pmf, $(p)_MAKE_FILE); \
		if [ "$${!pmf}" ]; then \
			$(call var, pmf, "$${mkfs_dir}/$${!pmf}"); \
		fi; \
	fi
endef

# Search for empty variables, and remove them
define remove_empty_vars
	$(call trim, file, $(1)); \
	sed -i.bak -e "/^[A-Za-z0-9_]*=$$/d" $$file && rm -f $${file}.bak; \
	sed -i.bak -e "/^[A-Za-z0-9_]*=%[A-Za-z0-9_]*%$$/d" $$file && rm -f $${file}.bak
endef

# Get all available projects in an array
define get_dcutil_projects
	projects=(`echo $${PROJECTS//:/ }`)
endef

# Check if the given project name exist
define check_dcutil_project_exist
	$(call get_dcutil_projects); \
	$(call trim, value, $(1)); \
	if [[ "$${projects[@]}" =~ "$$value" ]]; then \
		exist=true; \
	else \
		exist=false; \
	fi
endef

# Get the total number of dcutil projects available
define get_dcutil_projects_total
	$(call get_dcutil_projects); \
	total=$${#projects[@]}
endef

# Get the  project with the key
define get_dcutil_project
	$(call get_dcutil_projects); \
	$(call trim, index, $(1)); \
	(( "$${index}" > 0 )) && project=$${projects["$$(( $${index} - 1 ))"]}
endef

# Set DCUTIL project
define set_dcutil_project
	$(call trim, project, $(1)); \
	$(call is_valid_project_name, $$project); \
	if [ -f ".env" ] && [ "$$valid" == true ]; then \
		$(call check_dcutil_project_exist, $$project); \
		if [ "$$PROJECTS" ] && [ "$$exist" == "false" ]; then \
			old_data="PROJECTS=$${PROJECTS}"; \
			$(call replace_or_update, $${old_data}, "$${old_data}:$${project}", .env); \
		elif [ -z "$$PROJECTS" ]; then \
			$(call find_replace, "PROJECTS=", "PROJECTS=$$project", .env); \
		fi;\
		set=true; \
	else \
		set=false; \
	fi
endef

# Check if given project name is valid
define is_valid_project_name
	$(call trim, project_name, $(1)); \
	pattern=" |-"; \
    [[ $$project_name =~ $$pattern ]] && valid=false || valid=true
endef