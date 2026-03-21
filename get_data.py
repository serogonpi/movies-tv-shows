import kagglehub
import pandas as pd
import glob
import os

from google.cloud import storage

# My google bucket storage name
BUCKET_NAME = "movies-tv-show-19032026"

# Download Data
hulu_path = kagglehub.dataset_download("shivamb/hulu-movies-and-tv-shows", output_dir='./data/hulu')
netflix_path = kagglehub.dataset_download("shivamb/netflix-shows", output_dir='./data/netflix')
amazon_path = kagglehub.dataset_download("shivamb/amazon-prime-movies-and-tv-shows", output_dir='./data/amazon')
disney_path = kagglehub.dataset_download("shivamb/disney-movies-and-tv-shows", output_dir='./data/disney')

# List of downloaded files
downloaded_files_path = glob.glob('./data/*/*.csv')
print(downloaded_files_path)

# Start connection client
client = storage.Client()

# Get bucket reference
bucket = client.bucket(BUCKET_NAME)

for file in downloaded_files_path:
    filename = os.path.basename(file)
    name = os.path.basename(os.path.dirname(file))

    # Define destiny inside bucket
    blob = bucket.blob(f"{name}/{filename}")
    
    # Upload local file
    blob.upload_from_filename(file)


