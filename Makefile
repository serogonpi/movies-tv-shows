.PHONY: setup infra data pipeline all clean clean-bq test

setup:
	uv sync

infra:
	cd terraform && terraform init && terraform plan && terraform apply

data:
	uv run python get_data.py

clean-bq:
	bq rm -f -t movies-shows-pipeline-19032026:movies_tv_shows.raw_netflix
	bq rm -f -t movies-shows-pipeline-19032026:movies_tv_shows.raw_hulu
	bq rm -f -t movies-shows-pipeline-19032026:movies_tv_shows.raw_amazon
	bq rm -f -t movies-shows-pipeline-19032026:movies_tv_shows.raw_disney_plus
	bq rm -f -t movies-shows-pipeline-19032026:movies_tv_shows.all_titles
	bq rm -f -t movies-shows-pipeline-19032026:movies_tv_shows._dlt_loads
	bq rm -f -t movies-shows-pipeline-19032026:movies_tv_shows._dlt_pipeline_state
	bq rm -f -t movies-shows-pipeline-19032026:movies_tv_shows._dlt_version

pipeline: clean-bq
	bruin run .

test:
	uv run pytest tests/ -v

all: setup infra data pipeline test

clean:
	cd terraform && terraform destroy