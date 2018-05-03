#---------------------------------------------------------------------------------------[ Printing functions ]----------
# Print into terminal with choice of color [1-7].
# 0 – Black.
# 1 – Red.
# 2 – Green.
# 3 – Yellow.
# 4 – Blue.
# 5 – Magenta.
# 6 – Cyan.
# 7 – White.
#-----------------------------------------------------------------------------------------------------------------------
define color_text
	tput setaf $(1); \
	[ "$3" ] && [ "$3" == "1" ] && tput bold; \
	printf $(2); \
	tput sgr0
endef

# Adds color to text and new line at the end
define print_color
	$(call color_text, $(1), $(2)'\n')
endef

# Print in dual colored text and new line at the end
define print_dual_color
	$(call color_text, $(1), $(2)); \
	$(call color_text, $(3), $(4)'\n')
endef

# Print in triple colored text and new line at the end
define print_triple_color
	$(call color_text, $(1), $(2)); \
	$(call color_text, $(3), $(4)); \
	$(call color_text, $(5), $(6)'\n')
endef

# Container enter printing
# $1 = command
# $2 = container
# $3 = shell
# $4 = user
define print_container_enter
	$(call color_text, 6, "Command: "); \
	$(call color_text, 7,"$(1)\n"); \
	$(call color_text, 6, "Container: "); \
	$(call color_text, 7,"$(2)\n"); \
	$(call color_text, 6, "Shell: "); \
	$(call color_text, 7,"$(3)\n"); \
	$(call color_text, 6, "User: "); \
	$(call color_text, 7,"$(4)\n"); \
	$(call color_text, 6, "Time: "); \
	$(call color_text, 7,"$$(date '+%Y-%m-%d %H:%M:%S')\n\n")
endef

# Container exit printing
define print_container_exit
	$(call color_text, 8, "\nExit; $$(date '+%Y-%m-%d %H:%M:%S')\n")
endef

# Running target printing
define print_running_target
	$(call trim, custom, $(1)); \
	custom=$${custom:-$@}; \
	$(call print_dual_color, 2, "running... ", 7, "$${custom}")
endef

# Target completed printing
define print_completed_target
	$(call trim, custom, $(1)); \
	custom=$${custom:-$@}; \
	$(call print_triple_color, 2, "√ ", 7, "$${custom} ", 2, "done")
endef

# Target failed printing
define print_failed_target
	$(call trim, custom, $(1)); \
	custom=$${custom:-$@}; \
	$(call print_triple_color, 1, "X ", 7, "$${custom} ", 1, "failed")
endef

# info printing
define print_target_info
	$(call print_dual_color, 6, " • ", 7, $(1))
endef

# general printing
define print_target_general
	$(call print_dual_color, 7, " • ", 7, $(1))
endef

# success printing
define print_target_success
	$(call print_dual_color, 2, " • ", 7, $(1))
endef

# error printing
define print_target_error
	$(call print_dual_color, 1, " • ", 7, $(1))
endef

# Print command for a specific type
define print_command
	$(call trim, name, $(1)); \
	$(call trim, commands, $(2)); \
	commands="$${commands// /\\n - }"; \
	$(call print_dual_color, 7, "\n$${name} commands: \n", 2, " - $${commands}")
endef

# Get the pmf target label for printing
define get_pmf_target_label
	$(call get_custom_project_makefile); \
    makefilename="$$(basename $${pmf})"; \
	$(call trim, target, $(1)); \
    pmf_target_label="$${makefilename} » $$target"
endef