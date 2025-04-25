# Used to send extracted images with metadata to Gemini for alt text generation
# This is actually run in Vertext AI Google Collab Notebook in Google Cloud
# see https://github.com/sul-dlss/exhibits/issues/2816

import vertexai
import csv
from google.cloud import storage

from io import StringIO

from vertexai.generative_models import (
    GenerationConfig,
    GenerativeModel,
    Part,
    HarmCategory,
    HarmBlockThreshold,
)
model_id = 'gemini-1.5-pro'
safety_settings = {
    HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    HarmCategory.HARM_CATEGORY_CIVIC_INTEGRITY: HarmBlockThreshold.BLOCK_ONLY_HIGH,
}
model = GenerativeModel(
    model_id,
    safety_settings=safety_settings,
)

# Define project information
PROJECT_ID = "sul-ai-sandbox"  # @param {type:"string"}
LOCATION = "us-central1"  # @param {type:"string"}
BUCKET_NAME = "cloud-ai-platform-e215f7f7-a526-4a66-902d-eb69384ef0c4"
DIRECTORY = "exhibits-alt-text/pilot-2"
INPUTFILE = f'{DIRECTORY}/images.csv'
OUTPUTFILE = f'{DIRECTORY}/output/generated-text.csv'

# Initialize Vertex AI
vertexai.init(project=PROJECT_ID, location=LOCATION)


# Send Google Cloud Storage Document to Vertex AI
def process_document(
    prompt: str,
    file_uri: str,
    generation_config: GenerationConfig | None = None,
) -> str:
    # Load file directly from Google Cloud Storage
    file_part = Part.from_uri(
      uri=file_uri,
      mime_type="image/jpeg",
    )

    # Load contents
    contents = [file_part, prompt]

    try:
      # Send to Gemini
      print("...sending to Gemini")
      response = model.generate_content(contents)#, generation_config=generation_config)

      return response.text.rstrip()
    except ValueError as e:
      # Handle the ValueError exception
      print(f"A ValueError occurred: {e}")
    except Exception as e:
        # Handle any other unforeseen errors
        print(f"An unexpected error occurred: {e}")

def get_blob(blob_name):
  print(f"Reading {blob_name}")
  client = storage.Client()
  bucket = client.bucket(BUCKET_NAME)
  return bucket.blob(blob_name)

def description(exhibit_name, exhibit_description, extra_text, file_uri):
  print(file_uri)
  prompt = f"""
  This is an image from the Stanford University exhibit entitled "{exhibit_name}".
  This exhibit is about: {exhibit_description}.
  This image has some extra descriptive text which appears next to the image which may be about the image: {extra_text}.
  Please briefly describe what is pictured in the image. Limit your response to 150 characters or fewer.
  Please avoid starting the description with "This is a photo of..." or "This is an image of...", just say what it is in the image."""
  print(prompt)
  return process_document(prompt, file_uri)

csv_buffer = StringIO()

# Create a CSV writer
writer = csv.writer(csv_buffer)

# Write header row
writer.writerow(["File", "Description"])

with get_blob(INPUTFILE).open() as csvfile:
  reader = csv.reader(csvfile)

  next(reader) # skip headers
  print("Processing...")
  count = 0
  for row in reader:
    count += 1
    exhibit_name = row[0]
    exhibit_description = row[1]
    extra_text = row[3]
    file_uri = f'gs://{BUCKET_NAME}/{DIRECTORY}/{count}.jpg'
    print(f"{count} : {file_uri}")
    writer.writerow([row[0], description(exhibit_name, exhibit_description, extra_text, file_uri)])
    print()

print(f"Completed {count} rows")
# Get the CSV content as a string
csv_content = csv_buffer.getvalue()
get_blob(OUTPUTFILE).upload_from_string(csv_content, content_type='text/csv')
