#-------------------------------------------------------------------------------------------------[ Includes ]----------
# If targets/functions/variables are reusable on multiple projects, it might make sense to break them into their own
# files and include them to avoid repetetions. To include makefles from within repo dcutil's libs directory, you can use
# full path, or use the ./libs relative url, which will point correctly to dcutil directory on your machine.
#-----------------------------------------------------------------------------------------------------------------------
include libs/printing-functions.mk
include libs/helper-functions.mk
include php_projects.mk
include laravel_projects.mk

#------------------------------------------------------------------------------------------------[ Variables ]----------
all_ts = prj_mgmt migration clone_project pkg_mgmt list_ts

#--------------------------------------------------------------------------------------------[ Phony targets ]----------
.PHONY : $(all_ts)

#--------------------------------------------------------------------------------------------------[ Targets ]----------
list_ts :
	@echo $(all_ts)

prj_mgmt : clone_project pkg_mgmt migration