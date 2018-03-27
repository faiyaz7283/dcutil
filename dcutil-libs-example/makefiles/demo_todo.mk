#-------------------------------------------------------------------------------------------------[ Includes ]----------
# If targets/functions/variables are reusable on multiple projects, it might be advisable to break them into includes
# file and share them to avoid repetetions. You must also use the full directory path for any custom makefiles. To
# include makefles from within repo dcutil's libs directory, you can use full path, or use the ./libs relative url,
# which will point correctly to dcutil directory on your machine.
#-----------------------------------------------------------------------------------------------------------------------
include ./libs/printing-functions.mk
include ./libs/helper-functions.mk
include <dcutil-libs>/makefiles/php_projects.mk
include <dcutil-libs>/makefiles/laravel_projects.mk

#------------------------------------------------------------------------------------------------[ Variables ]----------
all_ts = prj_mgmt migration clone_project pkg_mgmt list_ts

#--------------------------------------------------------------------------------------------[ Phony targets ]----------
.PHONY : $(all_ts)

#--------------------------------------------------------------------------------------------------[ Targets ]----------
list_ts :
	@echo $(all_ts)

prj_mgmt : clone_project pkg_mgmt migration