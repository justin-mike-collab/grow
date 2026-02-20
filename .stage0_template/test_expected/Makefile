.PHONY: help install update spark-runbook schemas container push build-publish

help:
	@echo "Mentor Hub Developer CLI - Available commands:"
	@echo ""
	@echo "  make install        - Install mentorhub CLI tools to ~/.mentorhub"
	@echo "  make update         - Update mentorhub CLI tools and configure Docker/Git"
	@echo "  make schemas        - Fetch JSON schemas for all data dictionaries, assumes mongodb_api is running"
	@echo "  make container      - Build the Mentor Hub welcome page Docker container locally"
	@echo ""
	@echo "For more information, see ./DeveloperEdition/README.md"

install:
	@echo "Installing mentorhub CLI..."
	@mkdir -p ~/.mentorhub
	@if ! grep -q "Added by mentorhub CLI install" ~/.zshrc 2>/dev/null; then \
		echo "\n# Added by mentorhub CLI install" >> ~/.zshrc; \
		echo "export PATH=\$$PATH:~/.mentorhub" >> ~/.zshrc; \
		echo "export GITHUB_TOKEN=\$$(cat ~/.mentorhub/GITHUB_TOKEN)" >> ~/.zshrc; \
		echo "Added ~/.mentorhub to PATH in ~/.zshrc"; \
	else \
		echo "~/.mentorhub already in PATH"; \
	fi
	@echo "Installation complete. Run 'source ~/.zshrc' or restart your terminal."

uninstall:
	@echo "Uninstalling mentorhub CLI..."
	@if [ -f ~/.zshrc ]; then \
		grep -v -e 'Added by mentorhub CLI install' \
			-e 'export PATH=.*~/.mentorhub' \
			-e 'export GITHUB_TOKEN=.*mentorhub/GITHUB_TOKEN' \
			~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc && \
		echo "Removed mentorhub lines from ~/.zshrc"; \
	else \
		echo "~/.zshrc not found, skipping"; \
	fi
	@rm -rf ~/.mentorhub && echo "Removed ~/.mentorhub"
	@echo "Uninstall complete. Run 'source ~/.zshrc' or restart your terminal."

update:
	@echo "Updating mentorhub CLI..."
	@if [ ! -f ~/.mentorhub/GITHUB_TOKEN ]; then \
		echo "Error: GITHUB_TOKEN not found! - See ./DeveloperEdition/README.md"; \
		exit 1; \
	fi
	@cp ./DeveloperEdition/mh ~/.mentorhub/mh && \
	chmod +x ~/.mentorhub/mh && \
	cp ./DeveloperEdition/docker-compose.yaml ~/.mentorhub/docker-compose.yaml && \
	GITHUB_TOKEN=$$(cat ~/.mentorhub/GITHUB_TOKEN) && \
	echo "$$GITHUB_TOKEN" | docker login ghcr.io -u agile-learning-institute --password-stdin && \
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
	@echo "Building Mentor Hub container..."
	@DOCKER_BUILDKIT=0 docker build -t ghcr.io/agile-learning-institute/mentorhub:latest .
	@echo "Container built successfully: ghcr.io/agile-learning-institute/mentorhub:latest"

push:
	@echo "Pushing Mentor Hub container..."
	@docker push ghcr.io/agile-learning-institute/mentorhub:latest
	@echo "Container Pushed successfully: ghcr.io/agile-learning-institute/mentorhub:latest"

build-publish: container push