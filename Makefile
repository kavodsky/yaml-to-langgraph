# yaml-to-langgraph Makefile
# Convenient commands for development, testing, and package management

.PHONY: help install install-dev test test-cov lint format clean build publish docs

# Default target
help:
	@echo "yaml-to-langgraph Development Commands"
	@echo "======================================"
	@echo ""
	@echo "Development:"
	@echo "  install-dev    Install package in development mode with all dependencies"
	@echo "  install        Install package in production mode"
	@echo "  clean          Clean build artifacts and cache files"
	@echo ""
	@echo "Testing:"
	@echo "  test           Run all tests"
	@echo "  test-cov       Run tests with coverage report"
	@echo "  test-sample    Run sample workflow tests only"
	@echo "  test-cli       Run CLI tests only"
	@echo "  test-schema    Run schema validation tests only"
	@echo ""
	@echo "Code Quality:"
	@echo "  lint           Run linting (ruff, mypy)"
	@echo "  format         Format code (black, isort)"
	@echo "  check          Run all code quality checks"
	@echo ""
	@echo "Package Management:"
	@echo "  build          Build the package (using uv)"
	@echo "  publish        Publish to PyPI (using uv, requires token)"
	@echo "  publish-token  Publish with token (use TOKEN=your-token)"
	@echo "  publish-test   Publish to Test PyPI (use TOKEN=your-token)"
	@echo "  publish-twine  Publish using twine (reads ~/.pypirc)"
	@echo "  pypi-help      Show PyPI token setup instructions"
	@echo "  docs           Generate documentation"
	@echo ""
	@echo "UV Commands:"
	@echo "  uv-sync        Sync dependencies with uv"
	@echo "  uv-lock        Update lock file"
	@echo "  uv-update      Update dependencies"
	@echo "  uv-add         Add package (use PACKAGE=name)"
	@echo "  uv-add-dev     Add dev package (use PACKAGE=name)"
	@echo ""
	@echo "CLI Examples:"
	@echo "  demo           Run demo conversion with sample workflow"
	@echo "  validate-demo  Validate sample workflow"

# Development installation
install-dev:
	@echo "Installing yaml-to-langgraph in development mode..."
	uv pip install -e ".[dev,langchain]"

# Production installation
install:
	@echo "Installing yaml-to-langgraph..."
	uv pip install .

# Clean build artifacts and cache
clean:
	@echo "Cleaning build artifacts..."
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -rf htmlcov/
	rm -rf demo_output/
	rm -rf output_*/
	rm -rf test_*_output/
	rm -rf test_*_content/
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.pyd" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +

# Testing
test:
	@echo "Running all tests..."
	python -m pytest tests/ -v

test-cov:
	@echo "Running tests with coverage..."
	python -m pytest tests/ --cov=src/yaml_to_langgraph --cov-report=term-missing --cov-report=html

test-sample:
	@echo "Running sample workflow tests..."
	python -m pytest tests/test_sample_workflow.py -v

test-cli:
	@echo "Running CLI tests..."
	python -m pytest tests/test_cli.py -v

test-schema:
	@echo "Running schema validation tests..."
	python -m pytest tests/test_schema_validation.py -v

test-converter:
	@echo "Running converter tests..."
	python -m pytest tests/test_converter.py -v

# Code quality
lint:
	@echo "Running linting..."
	ruff check src/ tests/
	mypy src/

format:
	@echo "Formatting code..."
	black src/ tests/
	isort src/ tests/

check: lint test
	@echo "All checks passed!"

# Package management
build:
	@echo "Building package..."
	uv build

publish: build
	@echo "Publishing to PyPI..."
	@echo "Note: PyPI no longer supports username/password authentication."
	@echo "Please use 'make publish-token TOKEN=your-pypi-token' instead."
	@echo "Or set UV_PUBLISH_TOKEN environment variable and run 'uv publish'"
	@if [ -z "$$UV_PUBLISH_TOKEN" ]; then \
		echo "Error: UV_PUBLISH_TOKEN not set. Use 'make publish-token TOKEN=your-token'"; \
		exit 1; \
	fi
	uv publish

publish-token: build
	@echo "Publishing to PyPI with token..."
	@if [ -z "$(TOKEN)" ]; then echo "Usage: make publish-token TOKEN=your-pypi-token"; exit 1; fi
	UV_PUBLISH_TOKEN=$(TOKEN) uv publish

publish-test: build
	@echo "Publishing to Test PyPI..."
	@if [ -z "$(TOKEN)" ]; then echo "Usage: make publish-test TOKEN=your-testpypi-token"; exit 1; fi
	UV_PUBLISH_TOKEN=$(TOKEN) uv publish --repository testpypi

# Fallback to twine for users who prefer .pypirc
publish-twine: build
	@echo "Publishing to PyPI using twine (reads ~/.pypirc)..."
	python -m twine upload dist/*

publish-test-twine: build
	@echo "Publishing to Test PyPI using twine (reads ~/.pypirc)..."
	python -m twine upload --repository testpypi dist/*

# Helper commands for PyPI setup
pypi-help:
	@echo "PyPI Publishing Setup:"
	@echo "====================="
	@echo ""
	@echo "1. Get your PyPI API token:"
	@echo "   - Go to https://pypi.org/manage/account/token/"
	@echo "   - Create a new API token"
	@echo "   - Copy the token (starts with 'pypi-')"
	@echo ""
	@echo "2. Publish using the token:"
	@echo "   make publish-token TOKEN=your-pypi-token"
	@echo ""
	@echo "3. Or set environment variable:"
	@echo "   export UV_PUBLISH_TOKEN=your-pypi-token"
	@echo "   make publish"
	@echo ""
	@echo "4. For Test PyPI:"
	@echo "   - Get token from https://test.pypi.org/manage/account/token/"
	@echo "   - make publish-test TOKEN=your-testpypi-token"

docs:
	@echo "Generating documentation..."
	@echo "Documentation generation not yet implemented"

# CLI examples
demo:
	@echo "Running demo conversion..."
	python -m yaml_to_langgraph convert tests/exports/sample_workflow.yml --output demo_output

validate-demo:
	@echo "Validating sample workflow..."
	python -m yaml_to_langgraph validate tests/exports/sample_workflow.yml

validate-demo-strict:
	@echo "Validating sample workflow in strict mode..."
	python -m yaml_to_langgraph validate tests/exports/sample_workflow.yml --strict

# Development workflow
dev-setup: install-dev
	@echo "Development environment setup complete!"
	@echo "Run 'make test' to verify installation"

# UV-specific commands
uv-sync:
	@echo "Syncing dependencies with uv..."
	uv sync

uv-lock:
	@echo "Updating lock file..."
	uv lock

uv-update:
	@echo "Updating dependencies..."
	uv lock --upgrade

uv-add:
	@echo "Usage: make uv-add PACKAGE=package-name"
	@if [ -z "$(PACKAGE)" ]; then echo "Please specify PACKAGE=package-name"; exit 1; fi
	uv add $(PACKAGE)

uv-add-dev:
	@echo "Usage: make uv-add-dev PACKAGE=package-name"
	@if [ -z "$(PACKAGE)" ]; then echo "Please specify PACKAGE=package-name"; exit 1; fi
	uv add --dev $(PACKAGE)

# Quick development cycle
dev-test: format lint test
	@echo "Development cycle complete!"

# CI/CD simulation
ci: clean uv-sync lint test-cov
	@echo "CI pipeline simulation complete!"

# Show package info
info:
	@echo "Package Information:"
	@echo "==================="
	@python -c "import yaml_to_langgraph; print(f'Version: {yaml_to_langgraph.__version__}')"
	@echo "Location: $$(python -c 'import yaml_to_langgraph; print(yaml_to_langgraph.__file__)')"
	@echo "CLI available: $$(which yaml-to-langgraph 2>/dev/null || echo 'Not installed')"

# Show test coverage summary
coverage-summary:
	@echo "Coverage Summary:"
	@echo "================"
	python -m pytest tests/ --cov=src/yaml_to_langgraph --cov-report=term-missing --quiet

# Run specific test with verbose output
test-verbose:
	@echo "Running tests with verbose output..."
	python -m pytest tests/ -vvv

# Run tests in parallel (if pytest-xdist is installed)
test-parallel:
	@echo "Running tests in parallel..."
	python -m pytest tests/ -n auto

# Show help for CLI
cli-help:
	@echo "CLI Help:"
	@echo "========="
	python -m yaml_to_langgraph --help

# Validate all YAML files in tests/exports
validate-all:
	@echo "Validating all YAML files in tests/exports..."
	@for file in tests/exports/*.yml; do \
		echo "Validating $$file..."; \
		python -m yaml_to_langgraph validate "$$file" || exit 1; \
	done
	@echo "All YAML files are valid!"

# Convert all YAML files in tests/exports
convert-all:
	@echo "Converting all YAML files in tests/exports..."
	@for file in tests/exports/*.yml; do \
		basename=$$(basename "$$file" .yml); \
		echo "Converting $$file to output_$$basename..."; \
		python -m yaml_to_langgraph convert "$$file" --output "output_$$basename" || exit 1; \
	done
	@echo "All YAML files converted successfully!"
