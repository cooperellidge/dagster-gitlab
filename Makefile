# Shoutout cargo-bins/cargo-quickinstall for the help command below
.PHONY: help
help: ## Display this help screen
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.venv:  ## Create a virtual environment from lockfile
	uv sync --locked

.PHONY: format
format: ##  Fix imports and formatting
	ruff check --fix --select I 
	ruff format src tests

.PHONY: types
types:  # Run the type checker
	mypy src
	mypy tests

.PHONY: lint
lint:  ## Run the linter
	ruff check src tests

.PHONY: test
test:  ## Run unit tests
	uv run pytest tests
