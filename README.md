# ZSH AI Autocomplete

A ZSH plugin that uses AI models (OpenAI or Anthropic) to suggest command line completions based on your current terminal context.

## Features

- Trigger with `CTRL+K` to get AI-powered command suggestions
- Uses your current terminal input and last 10 commands as context
- Supports multiple AI providers (OpenAI and Anthropic Claude)
- Automatic provider selection based on available API keys
- Fast and efficient Go-based backend

## Prerequisites

- [oh-my-zsh](https://ohmyz.sh/)
- [Go](https://golang.org/) (1.16 or later)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/vncsna/zsh-ai-autocomplete
cd zsh-ai-autocomplete
```

2. Run the installation script:
```bash
make install
```
This will:
- Build the Go executable
- Copy the plugin to your oh-my-zsh custom plugins directory
- Show you the next steps

3. Add your API key to `~/.zshrc` (choose one or both):
```bash
# For OpenAI (preferred if both are set)
export OPENAI_API_KEY="your-api-key-here"

# For Anthropic Claude
export ANTHROPIC_API_KEY="your-api-key-here"
```

4. Enable the plugin in your `~/.zshrc`:
```bash
plugins=(... zsh-ai-autocomplete)
```

5. Restart your terminal or run:
```bash
source ~/.zshrc
```

## Usage

1. Start typing a command in your terminal
2. Press `CTRL+K` to get an AI-powered suggestion
3. The suggestion will appear inline and can be accepted with `Enter` or rejected with `Ctrl+C`

## Configuration

You can configure the following environment variables:

### Provider Selection
The plugin automatically selects the provider based on available API keys:
- If `OPENAI_API_KEY` is set, it uses OpenAI
- If only `ANTHROPIC_API_KEY` is set, it uses Anthropic
- You can force a specific provider with `ZSH_AI_PROVIDER="openai"` or `ZSH_AI_PROVIDER="anthropic"`

### OpenAI Configuration
- `OPENAI_API_KEY`: Your OpenAI API key
- `ZSH_AI_MODEL`: OpenAI model to use (default: "gpt-3.5-turbo")
- `ZSH_AI_MAX_TOKENS`: Maximum tokens for completion (default: 100)

### Anthropic Configuration
- `ANTHROPIC_API_KEY`: Your Anthropic API key
- `ZSH_AI_ANTHROPIC_MODEL`: Anthropic model to use (default: "claude-3-opus-20240229")

## License

MIT License - See LICENSE file for details