.PHONY: setup infra data pipeline all clean

setup:
	uv sync

infra:
	cd terraform && terraform init && terraform plan && terraform apply

data:
	uv run python get_data.py

pipeline:
	cd bruin && bruin run .

all: setup infra data pipeline

clean:
	cd terraform && terraform destroy
