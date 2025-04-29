0=${(%):-%N}
PLUGIN_DIR=${0:A:h}

# Debug helper function
function debug() {
    if [[ -n "$ZSH_AI_AUTOCOMPLETE_DEBUG" ]]; then
        echo "[DEBUG] $1"
    fi
}

debug "Loading zsh-ai-autocomplete plugin from $PLUGIN_DIR"

# Ensure the binary directory exists
mkdir -p "$PLUGIN_DIR/bin"

# Check if the executable exists
if [[ ! -x "$PLUGIN_DIR/bin/ai-suggest" ]]; then
    echo "[zsh-ai-autocomplete] Error: ai-suggest executable not found. Please run 'make install' in the plugin directory."
    return 1
fi

debug "Found ai-suggest executable at $PLUGIN_DIR/bin/ai-suggest"

# Check API keys
if [[ -n "$OPENAI_API_KEY" ]]; then
    debug "OPENAI_API_KEY is set"
elif [[ -n "$ANTHROPIC_API_KEY" ]]; then
    debug "ANTHROPIC_API_KEY is set"
else
    debug "No API keys found"
fi

# Function to get command suggestions
function _zsh_ai_autocomplete_suggestion() {
    debug "Triggered suggestion function"
    local current_buffer="$BUFFER"
    local current_dir="$PWD"
    local history_cmds=(${(f)"$(fc -ln -10 2>/dev/null || echo '')"})

    # Properly escape the command and directory for JSON
    local escaped_buffer="${current_buffer//\"/\\\"}"
    local escaped_dir="${current_dir//\"/\\\"}"
    
    # Create JSON input for the Go executable
    local json_input="{\"current_command\":\"$escaped_buffer\",\"working_dir\":\"$escaped_dir\",\"history\":[$(for cmd in "${history_cmds[@]}"; do echo -n "\"${cmd//\"/\\\"}\","; done | sed 's/,$//')]}"

    debug "JSON input: $json_input"

    # Call the Go executable and get the suggestion
    local suggestion
    if [[ -n "$OPENAI_API_KEY" ]]; then
        suggestion=$(OPENAI_API_KEY="$OPENAI_API_KEY" "$PLUGIN_DIR/bin/ai-suggest" --input "$json_input" 2>&1)
        local exit_code=$?
        debug "Exit code: $exit_code"
        debug "Raw suggestion: $suggestion"
    elif [[ -n "$ANTHROPIC_API_KEY" ]]; then
        suggestion=$(ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" "$PLUGIN_DIR/bin/ai-suggest" --input "$json_input" 2>&1)
        local exit_code=$?
        debug "Exit code: $exit_code"
        debug "Raw suggestion: $suggestion"
    else
        debug "No API keys available"
        return 1
    fi
    
    if [ $exit_code -eq 0 ] && [ -n "$suggestion" ]; then
        # Clear the current line
        zle kill-whole-line
        
        # Insert the suggestion
        BUFFER="$suggestion"
        CURSOR=$#BUFFER
        
        # Refresh the display
        zle redisplay
        debug "Suggestion applied: $BUFFER"
    else
        debug "Failed to get suggestion or suggestion was empty"
        debug "Error output: $suggestion"
    fi
}

# Create the ZLE widget
zle -N _zsh_ai_autocomplete_suggestion

# Bind Ctrl+K to the widget
bindkey '^K' _zsh_ai_autocomplete_suggestion

debug "Plugin loaded and CTRL+K bound"