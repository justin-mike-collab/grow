.PHONY: help install update spark-runbook schemas container push build-publish

help:
	@echo "grow Developer CLI - Available commands:"
	@echo ""
	@echo "  make install        - Install grow CLI tools to ~/.grow"
	@echo "  make update         - Update grow CLI tools and configure Docker/Git"
	@echo "  make schemas        - Fetch JSON schemas for all data dictionaries, assumes mongodb_api is running"
	@echo "  make container      - Build the grow welcome page Docker container locally"
	@echo ""
	@echo "For more information, see ./DeveloperEdition/README.md"

install:
	@echo "Installing grow CLI..."
	@mkdir -p ~/.grow
	@if ! grep -q "Added by grow CLI install" ~/.zshrc 2>/dev/null; then \
		echo "\n# Added by grow CLI install" >> ~/.zshrc; \
		echo "export PATH=\$$PATH:~/.grow" >> ~/.zshrc; \
		echo "export GITHUB_TOKEN=\$$(cat ~/.grow/GITHUB_TOKEN)" >> ~/.zshrc; \
		echo "Added ~/.grow to PATH in ~/.zshrc"; \
	else \
		echo "~/.grow already in PATH"; \
	fi
	@echo "Installation complete. Run 'source ~/.zshrc' or restart your terminal."

uninstall:
	@echo "Uninstalling grow CLI..."
	@if [ -f ~/.zshrc ]; then \
		grep -v -e 'Added by grow CLI install' \
			-e 'export PATH=.*~/.grow' \
			-e 'export GITHUB_TOKEN=.*grow/GITHUB_TOKEN' \
			~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc && \
		echo "Removed grow lines from ~/.zshrc"; \
	else \
		echo "~/.zshrc not found, skipping"; \
	fi
	@rm -rf ~/.grow && echo "Removed ~/.grow"
	@echo "Uninstall complete. Run 'source ~/.zshrc' or restart your terminal."

update:
	@echo "Updating grow CLI..."
	@if [ ! -f ~/.grow/GITHUB_TOKEN ]; then \
		echo "Error: GITHUB_TOKEN not found! - See ./DeveloperEdition/README.md"; \
		exit 1; \
	fi
	@cp ./DeveloperEdition/gr ~/.grow/gr && \
	chmod +x ~/.grow/gr && \
	cp ./DeveloperEdition/docker-compose.yaml ~/.grow/docker-compose.yaml && \
	GITHUB_TOKEN=$$(cat ~/.grow/GITHUB_TOKEN) && \
	echo "$$GITHUB_TOKEN" | docker login ghcr.io -u justin-mike-collab --password-stdin && \
	echo "Docker login completed" && \
	git config --global --unset-all url."https://@github.com/".insteadOf 2>/dev/null || true && \
	git config --global url."https://$$GITHUB_TOKEN@github.com/".insteadOf "https://github.com/" && \
	echo "Git URL configured" && \
	echo "Updates completed"

schemas:
	@echo "Fetching JSON schemas for all data dictionaries..."
	@mkdir -p ./Specifications/schemas
	@yq eval '.data_dictionaries[] | "\(.name)|\(.version)"' ./Specifications/catalog.yaml | \
	while IFS='|' read -r name; do \
		echo "Fetching schema for $${name}"; \
		curl -s "localhost:8180/api/configurations/json_schema/$${name}.yaml/0.1.0.0" > "./Specifications/schemas/$${name}.schema.json" \
		|| echo "Warning: Failed to fetch schema for $${name}"; \
	done
	@echo "Schema fetching complete."

container:
	@echo "Building grow container..."
	@DOCKER_BUILDKIT=0 docker build -t ghcr.io/justin-mike-collab/grow:latest .
	@echo "Container built successfully: ghcr.io/justin-mike-collab/grow:latest"

push:
	@echo "Pushing grow container..."
	@docker push ghcr.io/justin-mike-collab/grow:latest
	@echo "Container Pushed successfully: ghcr.io/justin-mike-collab/grow:latest"

build-publish: container push