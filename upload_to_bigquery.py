"""Sobe todos os CSVs da pasta data/ para o dataset raw no BigQuery."""
import os
import pandas as pd
from google.cloud import bigquery

PROJECT_ID = "arco-analytics-eng"
DATASET_ID = "raw"
DATA_DIR = os.path.join(os.path.dirname(__file__), "candidato", "data")

client = bigquery.Client(project=PROJECT_ID)

# Garante que o dataset existe
dataset_ref = bigquery.Dataset(f"{PROJECT_ID}.{DATASET_ID}")
dataset_ref.location = "southamerica-east1"
client.create_dataset(dataset_ref, exists_ok=True)
print(f"Dataset '{DATASET_ID}' pronto.\n")

csv_files = [f for f in os.listdir(DATA_DIR) if f.endswith(".csv")]

for csv_file in sorted(csv_files):
    table_name = csv_file.replace(".csv", "")
    file_path = os.path.join(DATA_DIR, csv_file)

    df = pd.read_csv(file_path, dtype=str)  # dtype=str evita inferência errada de tipos

    table_id = f"{PROJECT_ID}.{DATASET_ID}.{table_name}"
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        autodetect=True,
    )

    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result()

    table = client.get_table(table_id)
    print(f"✓ {table_name}: {table.num_rows} linhas")

print("\nUpload concluído!")
