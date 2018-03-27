#------------------------------------------------------------------------------[ Targets specific to Laravel ]----------
migration :
	@$(MAKE) docker_workstation cnt_user=phpdc cnt_shell=bash cmd="cd /var/www/demo_todo && php artisan migrate"
