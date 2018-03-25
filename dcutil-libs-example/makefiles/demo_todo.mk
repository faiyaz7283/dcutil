# Custom targets for demo_todo project.
# To use targets from this file with DCUTIL, call targets with double underscores.
# Example: dcutil p=demo_todo __<target-name>
migration:
	@$(MAKE) docker_workstation cnt_user=dcutil cnt_shell=bash cmd="cd /var/www/demo_todo && php artisan migrate"