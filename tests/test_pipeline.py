import glob
import pytest
from google.cloud import storage, bigquery

BUCKET_NAME = "movies-tv-show-19032026"
PROJECT_ID = "movies-shows-pipeline-19032026"
DATASET_ID = "movies_tv_shows"

EXPECTED_CSV_DIRS = ["hulu", "netflix", "amazon", "disney"]
EXPECTED_GCS_FILES = [
    "hulu/hulu_titles.csv",
    "netflix/netflix_titles.csv",
    "amazon/amazon_prime_titles.csv",
    "disney/disney_plus_titles.csv",
]
EXPECTED_TABLES = [
    "raw_hulu",
    "raw_netflix",
    "raw_amazon",
    "raw_disney_plus",
    "all_titles",
]


class TestLocalData:
    def test_csv_files_exist(self):
        csv_files = glob.glob("./data/*/*.csv")
        assert len(csv_files) >= 4, f"Expected at least 4 CSV files, found {len(csv_files)}"

    def test_each_platform_has_csv(self):
        for platform in EXPECTED_CSV_DIRS:
            files = glob.glob(f"./data/{platform}/*.csv")
            assert len(files) > 0, f"No CSV found for {platform}"


class TestGCS:
    @pytest.fixture(autouse=True)
    def setup(self):
        self.client = storage.Client()
        self.bucket = self.client.bucket(BUCKET_NAME)

    def test_bucket_exists(self):
        assert self.bucket.exists(), f"Bucket {BUCKET_NAME} does not exist"

    def test_csv_files_in_bucket(self):
        for file_path in EXPECTED_GCS_FILES:
            blob = self.bucket.blob(file_path)
            assert blob.exists(), f"File {file_path} not found in bucket"


class TestBigQuery:
    @pytest.fixture(autouse=True)
    def setup(self):
        self.client = bigquery.Client(project=PROJECT_ID)

    def test_tables_exist(self):
        tables = [t.table_id for t in self.client.list_tables(DATASET_ID)]
        for table in EXPECTED_TABLES:
            assert table in tables, f"Table {table} not found in BigQuery"

    def test_all_titles_has_data(self):
        query = f"SELECT COUNT(*) as total FROM `{PROJECT_ID}.{DATASET_ID}.all_titles`"
        result = list(self.client.query(query).result())
        assert result[0].total > 0, "all_titles table is empty"

    def test_all_titles_has_all_platforms(self):
        query = f"SELECT DISTINCT platform FROM `{PROJECT_ID}.{DATASET_ID}.all_titles`"
        result = [row.platform for row in self.client.query(query).result()]
        expected = ["netflix", "amazon_plus", "disney_plus", "hulu"]
        for platform in expected:
            assert platform in result, f"Platform {platform} not found in all_titles"
