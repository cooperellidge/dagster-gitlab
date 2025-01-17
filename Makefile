# Shoutout cargo-bins/cargo-quickinstall for the help command below
.PHONY: help
help: ## Display this help screen
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST)  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.venv:  ## Create a virtual environment from lockfile
	uv sync --locked

.PHONY: clean
clean:
	find ./src | grep -E "(__pycache__$$)" | xargs rm -rf
	find ./src | grep -E "(\.pyc$$)" | xargs rm -rf
	find ./src | grep -E "(\.pyo$$)" | xargs rm -rf


	find ./tests | grep -E "(__pycache__$$)" | xargs rm -rf
	find ./tests | grep -E "(\.pyc$$)" | xargs rm -rf
	find ./tests | grep -E "(\.pyo$$)" | xargs rm -rf

	rm -vrf .mypy_cache
	rm -vrf .pytest_cache
	rm -vrf .ruff_cache

	rm -vrf dist/

.PHONY: check-format
check-format: ##  Check formatting, but do not fix
	uv run ruff format src tests --check

.PHONY: format
format: ##  Fix imports and formatting
	uv run ruff check --fix --select I 
	uv run ruff format src tests

.PHONY: types
types:  # Run the type checker
	uv run mypy src
	uv run mypy tests

.PHONY: lint
lint:  ## Run the linter
	uv run ruff check src tests

.PHONY: test
test:  ## Run unit tests
	uv run pytest tests
