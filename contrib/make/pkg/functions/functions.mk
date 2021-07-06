# include $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../base/base.mk)

define rwildcard
$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
endef

# https://www.gnu.org/software/make/manual/html_node/Call-Function.html
define recursive_call
$(foreach a,$(2),$(call $(1),$(a)))
endef

define relative_to_absolute
$(realpath $1)
endef

define pathsearch
$(firstword $(wildcard $(addsuffix /$(1),$(subst :, ,$(PATH)))))
endef

define append_to_file
$(file >>$(1),$(2))
endef

define write_to_file
$(file >$(1),$(2))
endef

define empty_file
$(file >$(1),)
endef

define read_file_content
$(file < $(1))
endef

define canonical_path
$(patsubst ${CURDIR}/%,%,$(abspath ${1}))
endef

# MIN - Parameterized "function" that results in the minimum lexical value of
#   the two values given.
define MIN
$(firstword $(sort ${1} ${2}))
endef

# PEEK - Parameterized "function" that results in the value at the top of the
#   specified colon-delimited stack.
define PEEK
$(lastword $(subst :, ,${1}))
endef

# POP - Parameterized "function" that pops the top value off of the specified
#   colon-delimited stack, and results in the new value of the stack. Note that
#   the popped value cannot be obtained using this function; use peek for that.
define POP
${1:%:$(lastword $(subst :, ,${1}))=%}
endef

# PUSH - Parameterized "function" that pushes a value onto the specified colon-
#   delimited stack, and results in the new value of the stack.
define PUSH
${2:%=${1}:%}
endef

# QUALIFY_PATH - Given a "root" directory and one or more paths, qualifies the
#   paths using the "root" directory (i.e. appends the root directory name to
#   the paths) except for paths that are absolute.
define QUALIFY_PATH
$(addprefix ${1}/,$(filter-out /%,${2})) $(filter /%,${2})
endef

# Retrieves a host part of the given string (without port).
# Param:
#   1. String to parse in form 'host[:port]'.
define extract_host
$(firstword \
	$(subst :, ,$1)\
)
endef

# Returns a port (if any).
# If there is no port part in the string, returns the second argument
# (if specified).
# Param:
#   1. String to parse in form 'host[:port]'.
#   2. (optional) Fallback value.
define extract_port
$(or \
	$(word 2,\
		$(subst :, ,$1)\
	),$(value 2)\
)
endef
