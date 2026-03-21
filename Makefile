.PHONY: setup infra data pipeline all clean test

setup:
	uv sync

infra:
	cd terraform && terraform init && terraform plan && terraform apply

data:
	uv run python get_data.py

pipeline:
	cd bruin && bruin run .

test:
	uv run pytest tests/ -v

all: setup infra data pipeline test

clean:
	cd terraform && terraform destroy