# github.com/faiyaz7283/dcutil
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
define print_running_env_enter
	$(call trim, command, $(1)); \
	$(call color_text, ${CYAN}, "Command: "); \
	$(call color_text, ${WHITE},"$$command\n"); \
	$(call color_text, ${CYAN}, "Environment: "); \
	$(call color_text, ${WHITE},"$(2)\n"); \
	$(call color_text, ${CYAN}, "Time: "); \
	$(call color_text, ${WHITE},"$$(date '+%Y-%m-%d %H:%M:%S')\n\n")
endef

# Container exit printing
define print_running_env_exit
	$(call color_text, 8, "\nExit; $$(date '+%Y-%m-%d %H:%M:%S')\n")
endef

# Running target printing
define print_running_target
	$(call trim, custom, $(1)); \
	custom=$${custom:-$@}; \
	$(call print_dual_color, ${GREEN}, "running... ", ${WHITE}, "$${custom}")
endef

# Target completed printing
define print_completed_target
	$(call trim, custom, $(1)); \
	custom=$${custom:-$@}; \
	$(call print_triple_color, ${GREEN}, "√ ", ${WHITE}, "$$custom", ${GREEN}, " done")
endef
# Target completed printing
define print_completed_target_new
	$(call trim, custom, $(1)); \
	custom=$${custom:-$(1)}; \
	custom=[$@]" "$${custom}  ; \
	$(call print_triple_color, ${GREEN}, "√ ", ${WHITE}, "$$custom", ${GREEN}, "done")
endef
# Target failed printing
define print_failed_target
	$(call trim, custom, $(1)); \
	custom=$${custom:-$@}; \
	$(call print_triple_color, ${RED}, "X ", ${WHITE}, "$${custom} ", ${RED}, "failed")
endef

# info printing
define print_target_info
	$(call print_dual_color, ${CYAN}, " • ", ${WHITE}, $(1))
endef

# general printing
define print_target_general
	$(call print_dual_color, ${WHITE}, " • ", ${WHITE}, $(1))
endef

# success printing
define print_target_success
	$(call print_dual_color, ${GREEN}, " • ", ${WHITE}, $(1))
endef

# error printing
define print_target_error
	$(call print_dual_color, ${RED}, " • ", ${WHITE}, $(1))
endef

# Print command for a specific type
define print_command
	$(call trim, name, $(1)); \
	$(call trim, commands, $(2)); \
	commands="$${commands// /\\n - }"; \
	$(call print_dual_color, ${WHITE}, "\n$${name} commands: \n", ${GREEN}, " - $${commands}")
endef

# Get the pmf target label for printing
define get_pmf_target_label
	$(call get_custom_project_makefile); \
    makefilename="$$(basename $${pmf})"; \
	$(call trim, target, $(1)); \
    pmf_target_label="$${makefilename} » $$target"
endef
