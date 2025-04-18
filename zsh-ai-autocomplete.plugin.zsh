0=${(%):-%N}
PLUGIN_DIR=${0:A:h}

# Ensure the binary directory exists
mkdir -p "$PLUGIN_DIR/bin"

# Check if the executable exists
if [[ ! -x "$PLUGIN_DIR/bin/ai-suggest" ]]; then
    echo "[zsh-ai-autocomplete] Error: ai-suggest executable not found. Please run 'make install' in the plugin directory."
    return 1
fi

# Function to get command suggestions
function _zsh_ai_autocomplete_suggestion() {
    local current_buffer="$BUFFER"
    local current_dir="$PWD"
    local history_cmds=(${(f)"$(fc -ln -10 2>/dev/null)"})

    # Create JSON input for the Go executable
    local json_input=$(cat <<EOF
{
    "current_command": "${current_buffer//\"/\\\"}",
    "working_dir": "${current_dir//\"/\\\"}",
    "history": [$(for cmd in "${history_cmds[@]}"; do echo -n "\"${cmd//\"/\\\"}\","; done | sed 's/,$//')]}
EOF
)

    # Call the Go executable and get the suggestion
    local suggestion
    suggestion=$("$PLUGIN_DIR/bin/ai-suggest" --input "$json_input" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$suggestion" ]; then
        # Clear the current line
        zle kill-whole-line
        
        # Insert the suggestion
        BUFFER="$suggestion"
        CURSOR=$#BUFFER
        
        # Refresh the display
        zle redisplay
    fi
}

# Create the ZLE widget
zle -N _zsh_ai_autocomplete_suggestion

# Bind Ctrl+K to the widget
bindkey '^K' _zsh_ai_autocomplete_suggestion 