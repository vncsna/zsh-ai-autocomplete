package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"strings"

	"github.com/vncsna/zsh-ai-autocomplete/pkg/ai"
)

type Input struct {
	CurrentCommand string   `json:"current_command"`
	History        []string `json:"history"`
	WorkingDir     string   `json:"working_dir"`
}

func main() {
	// Parse flags
	inputJSON := flag.String("input", "", "JSON string containing terminal context")
	flag.Parse()

	if *inputJSON == "" {
		log.Fatal("Input JSON is required")
	}

	// Parse input JSON
	var input Input
	if err := json.Unmarshal([]byte(*inputJSON), &input); err != nil {
		log.Fatalf("Failed to parse input JSON: %v", err)
	}

	// Initialize AI provider
	provider, err := ai.NewProvider()
	if err != nil {
		log.Fatalf("Failed to initialize AI provider: %v", err)
	}

	// Build prompt
	prompt := buildPrompt(input)

	// Get suggestion from AI provider
	suggestion, err := provider.GetSuggestion(prompt)
	if err != nil {
		log.Fatalf("Failed to get suggestion: %v", err)
	}

	// Print suggestion to stdout
	fmt.Print(suggestion)
}

func buildPrompt(input Input) string {
	var sb strings.Builder

	sb.WriteString("You are a command-line assistant. Based on the following context, suggest a single command that would help the user achieve their goal.\n\n")
	sb.WriteString("Current working directory: " + input.WorkingDir + "\n\n")

	if len(input.History) > 0 {
		sb.WriteString("Recent commands:\n")
		for _, cmd := range input.History {
			sb.WriteString("- " + cmd + "\n")
		}
		sb.WriteString("\n")
	}

	sb.WriteString("Current partial command: " + input.CurrentCommand + "\n\n")
	sb.WriteString("Suggest a single command line that would help complete this task. Respond with only the command, no explanation.")

	return sb.String()
}
