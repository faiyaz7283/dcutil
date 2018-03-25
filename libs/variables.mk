#------------------------------------------------------------------------------------------------[ Variables ]----------
SHELL := /bin/bash
docker_compose = docker-compose -f $$docker_compose_files -p $(p)
silent = false
cnt_shell= sh
cnt_user = root
helper_ts = show_commands commands targets show_projects projects version help man rm_vars
validation_ts = check_not_root isset_p_param isset_valid_project_name is_wd_exist isset_env isset_valid_cf
setup_ts = set_code_project set_git_code_project
build_ts = full_build build_project build_docker
project_ts = composer_task migration
docker_ts = docker_start docker_stop docker_ps docker_up docker_up_detailed docker_down docker_login docker_cmd \
			docker_workstation docker_images
all_targets = $(helper_ts) $(validation_ts) $(setup_ts) $(build_ts) $(project_ts)
, = ,
