#------------------------------------------------------------------------------------------------[ Variables ]----------
SHELL := /bin/bash
docker_compose = docker-compose -f $$docker_compose_files -p $(p)
self_make = $(MAKE) -f "$$dcutil_root/Makefile" -I "$$dcutil_root"
silent = false
cnt_shell= sh
cnt_user = root
helper_ts = show_commands commands targets show_projects projects help man rm_vars
validation_ts = check_not_root isset_p isset_valid_p is_code_project_exist isset_env isset_valid_cf
build_ts = build
docker_ts = docker_start docker_stop docker_ps docker_up docker_up_detailed docker_down docker_login docker_cmd \
			docker_workstation docker_images
all_ts = $(helper_ts) $(validation_ts) $(setup_ts) $(build_ts) $(project_ts)
, = ,
