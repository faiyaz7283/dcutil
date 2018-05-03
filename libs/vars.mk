#---------------------------------------------------------------------------------------[ Required Variables ]----------
SHELL := /bin/bash
dc_compose = docker-compose -f $$docker_compose_files -p $(p)
self_make = $(MAKE) -f "$${dcutil_root}/Makefile" -I "$${dcutil_root}"
silent = false
cnt_shell= sh
cnt_user = root
helper_ts = show_commands commands targets show_projects projects rm_vars
validation_ts = check_not_root isset_p isset_valid_p isset_env isset_valid_cf
build_ts = build
dc_ts = dc_start dc_stop dc_ps dc_up dc_up_dependencies dc_down dc_login dc_cmd dc_images
all_ts = $(helper_ts) $(validation_ts) $(build_ts) $(dc_ts)
, = ,
