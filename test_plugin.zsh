#!/bin/zsh

echo "Testing without debug mode..."
echo "----------------------------"
unset ZSH_AI_AUTOCOMPLETE_DEBUG
source zsh-ai-autocomplete.plugin.zsh

# Mock ZLE functions for testing
function zle() {
    if [[ "$1" == "kill-whole-line" || "$1" == "redisplay" ]]; then
        return 0
    fi
    command zle "$@"
}

# Test without debug mode
BUFFER="ls -"
_zsh_ai_autocomplete_suggestion
echo "Suggestion: $BUFFER"
echo

echo "Testing with debug mode..."
echo "-------------------------"
export ZSH_AI_AUTOCOMPLETE_DEBUG=1
source zsh-ai-autocomplete.plugin.zsh

# Test with debug mode
BUFFER="ls -"
_zsh_ai_autocomplete_suggestion
echo "Suggestion: $BUFFER"

# Test 1: Basic command completion
echo "Test 1: Basic command completion"
BUFFER="ls -"
_zsh_ai_autocomplete_suggestion
echo "Suggestion: $BUFFER"
echo "---"

# Test 2: Git command completion
echo "Test 2: Git command completion"
BUFFER="git "
_zsh_ai_autocomplete_suggestion
echo "Suggestion: $BUFFER"
echo "---"

# Test 3: Complex command with history
echo "Test 3: Complex command with history"
BUFFER="find . -name "
_zsh_ai_autocomplete_suggestion
echo "Suggestion: $BUFFER"
echo "---"

# Test 4: Test with empty buffer
echo "Test 4: Empty buffer"
BUFFER=""
_zsh_ai_autocomplete_suggestion
echo "Suggestion: $BUFFER"
echo "---"

# Test 5: Test with invalid command
echo "Test 5: Invalid command"
BUFFER="xyz123 "
_zsh_ai_autocomplete_suggestion
echo "Suggestion: $BUFFER"
echo "---" 