package anthropic

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

type Client struct {
	apiKey     string
	model      string
	maxTokens  int
	httpClient *http.Client
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type Request struct {
	Model       string    `json:"model"`
	Messages    []Message `json:"messages"`
	MaxTokens   int       `json:"max_tokens"`
	Temperature float64   `json:"temperature"`
}

type Response struct {
	Content []struct {
		Text string `json:"text"`
	} `json:"content"`
}

func NewClient(apiKey string) *Client {
	model := os.Getenv("ZSH_AI_ANTHROPIC_MODEL")
	if model == "" {
		model = "claude-3-opus-20240229"
	}

	maxTokens := 100
	return &Client{
		apiKey:     apiKey,
		model:      model,
		maxTokens:  maxTokens,
		httpClient: &http.Client{},
	}
}

func (c *Client) GetSuggestion(prompt string) (string, error) {
	reqBody := Request{
		Model: c.model,
		Messages: []Message{
			{
				Role:    "system",
				Content: "You are a command-line assistant that suggests commands based on context.",
			},
			{
				Role:    "user",
				Content: prompt,
			},
		},
		MaxTokens:   c.maxTokens,
		Temperature: 0.7,
	}

	reqJSON, err := json.Marshal(reqBody)
	if err != nil {
		return "", fmt.Errorf("failed to marshal request: %v", err)
	}

	req, err := http.NewRequest("POST", "https://api.anthropic.com/v1/messages", bytes.NewBuffer(reqJSON))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %v", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", c.apiKey)
	req.Header.Set("anthropic-version", "2023-06-01")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to send request: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("API request failed with status %d: %s", resp.StatusCode, body)
	}

	var claudeResp Response
	if err := json.Unmarshal(body, &claudeResp); err != nil {
		return "", fmt.Errorf("failed to parse response: %v", err)
	}

	if len(claudeResp.Content) == 0 {
		return "", fmt.Errorf("no suggestions received")
	}

	return claudeResp.Content[0].Text, nil
}
