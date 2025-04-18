package ai

import (
	"fmt"
	"os"

	"github.com/vncsna/zsh-ai-autocomplete/pkg/anthropic"
	"github.com/vncsna/zsh-ai-autocomplete/pkg/openai"
)

// Provider defines the interface for AI providers
type Provider interface {
	GetSuggestion(prompt string) (string, error)
}

// NewProvider creates a new AI provider based on available API keys
func NewProvider() (Provider, error) {
	// Check for explicitly set provider
	provider := os.Getenv("ZSH_AI_PROVIDER")

	// If provider is explicitly set, respect that choice
	if provider != "" {
		switch provider {
		case "openai":
			apiKey := os.Getenv("OPENAI_API_KEY")
			if apiKey == "" {
				return nil, fmt.Errorf("OPENAI_API_KEY environment variable is required when ZSH_AI_PROVIDER=openai")
			}
			return openai.NewClient(apiKey), nil

		case "anthropic":
			apiKey := os.Getenv("ANTHROPIC_API_KEY")
			if apiKey == "" {
				return nil, fmt.Errorf("ANTHROPIC_API_KEY environment variable is required when ZSH_AI_PROVIDER=anthropic")
			}
			return anthropic.NewClient(apiKey), nil

		default:
			return nil, fmt.Errorf("unsupported AI provider: %s", provider)
		}
	}

	// Auto-detect provider based on available API keys
	openaiKey := os.Getenv("OPENAI_API_KEY")
	anthropicKey := os.Getenv("ANTHROPIC_API_KEY")

	// If both keys are set, prefer OpenAI
	if openaiKey != "" {
		return openai.NewClient(openaiKey), nil
	}

	if anthropicKey != "" {
		return anthropic.NewClient(anthropicKey), nil
	}

	return nil, fmt.Errorf("no API keys found. Set either OPENAI_API_KEY or ANTHROPIC_API_KEY")
}
