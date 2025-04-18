.PHONY: install build clean

ZSH_CUSTOM ?= ~/.oh-my-zsh/custom
PLUGIN_NAME = zsh-ai-autocomplete
PLUGIN_DIR = $(ZSH_CUSTOM)/plugins/$(PLUGIN_NAME)

install: build copy

build:
	@echo "Building ai-suggest executable..."
	@go build -o bin/ai-suggest cmd/ai-suggest/main.go

copy:
	@rm -rf $(PLUGIN_DIR)/*
	@mkdir -p $(PLUGIN_DIR)
	@cp -r . $(PLUGIN_DIR)
	@echo "Installation complete! Plugin installed to: $(PLUGIN_DIR)"
	@echo "Please ensure you:"
	@echo "1. Add your API key to ~/.zshrc"
	@echo "2. Add 'zsh-ai-autocomplete' to your plugins in ~/.zshrc"
	@echo "3. Run 'source ~/.zshrc' or restart your terminal"

clean:
	@echo "Cleaning up..."
	@rm -rf bin/ai-suggest
	@echo "Removing installed plugin..."
	@rm -rf $(PLUGIN_DIR)