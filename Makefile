install:
	pip3 install -e .

install-dev:
	pip3 install -e ".[dev]"
	pre-commit install

test:
	pytest

test-coverage:
	pytest --cov=brag --cov-report=html
	open htmlcov/index.html

format:
	black brag tests
	isort brag tests

lint:
	flake8 brag tests --max-line-length=100

clean:
	rm -rf build dist *.egg-info .pytest_cache htmlcov
