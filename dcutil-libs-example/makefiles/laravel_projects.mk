#------------------------------------------------------------------------------[ Targets specific to Laravel ]----------
migration :
	@$(MAKE) docker_workstation cmd="cd /var/www/demo_todo && php artisan migrate"
