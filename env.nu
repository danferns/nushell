# Nushell Environment Config File

def create_left_prompt [] {
    let path_segment = if (is-admin) {
        $"(ansi red_bold)($env.PWD)"
    } else {
        $"(ansi xterm_springgreen1)($env.PWD)"
    }

    # get the current branch / commit ref
    use std
    let git_current_ref = $"(git rev-parse --abbrev-ref HEAD e> (std null-device))"
    let git_segment = if ($git_current_ref != "") {
        $"(ansi reset) | (ansi yellow)($git_current_ref)" 
    }

    let prompt = $"($path_segment)($git_segment)"
    $prompt
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | format date '%r')
    ] | str join)

    ''
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = { $"(ansi white) 〉 (ansi reset)" }
$env.PROMPT_INDICATOR_VI_INSERT = { $"(ansi white) 〉 (ansi reset)" }
$env.PROMPT_INDICATOR_VI_NORMAL = { $"(ansi yellow) 〉 (ansi reset)" }
$env.PROMPT_MULTILINE_INDICATOR = { "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

# custom editor
$env.EDITOR = "nvim"

def gl [] {
   git log --pretty=%aD»¦«%aN»¦«%h»¦«%s -n 1000 | lines | split column "»¦«" date name commit subject | upsert date {|d| $d.date | into datetime} | explore 
}
