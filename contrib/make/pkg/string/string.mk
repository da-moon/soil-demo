# github.com/faiyaz7283/dcutil
# Convert string to upper
define to_upper
	$(1)=$$(echo $(2) | tr '[:lower:]' '[:upper:]')
endef

# Convert string to lower
define to_lower
	$(1)=$$(echo $(2) | tr '[:upper:]' '[:lower:]')
endef


# Trim white spaces
define trim
	value="$(2)"; \
	$(1)=$$(echo $${value%/} | xargs)
endef

# Set a var
define var
	$(call trim, value, $(2)); \
	$(1)="$$value"
endef
# Search for string, replace with string in the given file
define find_replace
	if [ "$(4)" ]; then \
		$(call trim, dlm, $(4)); \
	else \
		dlm=#; \
	fi; \
	$(call trim, find, $(1)); \
	$(call trim, replace, $(2)); \
	$(call trim, file, $(3)); \
	sed -i.bak -e "s$${dlm}$${find}$${dlm}$${replace}$${dlm}g" $$file && rm -f $${file}.bak
endef

# Replace or update
define replace_or_update
	$(call trim, var_name, $(1)); \
	var_name=$${var_name%'%'}; \
	var_name=$${var_name#'%'}; \
        $(call find_replace, $(1), $(2), $(3), $${4:-#}); \
	if [ "$${!var_name}" ] && [ -f "$${file}.backup" ]; then \
		$(call remove_matching_lines, $$var_name, $${file}.backup); \
	fi
endef

# Search for matching string, and remove the entire line
define remove_matching_lines
	$(call trim, find, $(1)); \
	$(call trim, file, $(2)); \
	sed -i.bak -e "/$${find}/d" $$file && rm -f $${file}.bak
endef

define remove_empty_lines
	$(call trim, file, $(1)); \
	sed -i.bak -e "/^[[:space:]]*$$/d" $$file && rm -f $${file}.bak
endef
