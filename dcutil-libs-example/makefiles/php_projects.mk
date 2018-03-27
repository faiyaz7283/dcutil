#-------------------------------------------------------------------------[ Targets specific to PHP projects ]----------
clone_project :
	@if ! $(MAKE) is_code_project_exist > /dev/null 2>&1; then \
		if [ -z "$$repo" ]; then \
			echo "Enter your git repository url: "; \
			read repo; \
		fi; \
		$(call get_wd); \
		if [ "$$wd" ]; then \
			cd $$wd; \
			git clone $$repo ./$(p); \
		fi; \
	fi

pkg_mgmt :
	@$(call get_wd); \
	if [ "$$wd" ]; then \
		cd $$wd/$(p); \
		if [ -f "composer.json" ]; then \
			if composer --dry-run install > /dev/null 2>&1; then \
				$(call print_target_info, "Composer install started."); \
				composer install; \
				$(call print_target_success, "Composer install completed."); \
			else \
				$(call print_target_error, "Composer failed to run."); \
			fi; \
		else \
			$(call print_target_error, "Missing composer.json file."); \
		fi; \
	fi

#------------------------------------------------------------------------------------------------[ Functions ]----------
define get_wd
	wd=`[ "$$HOST_WORKING_DIR" ] && echo $$HOST_WORKING_DIR || echo $$DEMO_TODO_WORKING_DIR`
endef

