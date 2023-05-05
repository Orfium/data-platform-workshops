#!make

help:
	@echo "Please use 'make <target>' where <target> is one of the following:"
	@echo "  deps                               to install dbt project dependencies."
	@echo "  dev-deps                           to install dev dependencies."
	@echo "  pre-commit                          to run pre-commit checks."

deps:
	pip install --upgrade pip
	pip install -r requirements.txt
	dbt deps

dev-deps: deps
	pip install -r requirements_dev.txt

pre-commit:
	pre-commit run $(args)
