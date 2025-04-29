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

# Define project information
PROJECT_ID = "sul-ai-sandbox"  # @param {type:"string"}
LOCATION = "us-central1"  # @param {type:"string"}
BUCKET_NAME = "cloud-ai-platform-e215f7f7-a526-4a66-902d-eb69384ef0c4"
DIRECTORY = "exhibits-alt-text/pilot-2"
INPUTFILE = f'{DIRECTORY}/images.csv'
OUTPUTFILE = f'{DIRECTORY}/output/generated-text.csv'
MODEL_ID = 'gemini-2.0-flash'
# other options (see Google AI Studio for more):
# "gemini-2.5-pro-preview-03-25"
# "gemini-1.5-pro"
TEST_LIMIT = None # 30 # limit the number of images to process for testing, set to None to process all
DEBUG = False # set to True to see more debug output (like the full prompt)
ONLY_USE_EXHIBIT_NAME = None # "Digitization Exemplars" # limit to this exhibit name, set to None to process all

safety_settings = {
    HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    HarmCategory.HARM_CATEGORY_CIVIC_INTEGRITY: HarmBlockThreshold.BLOCK_ONLY_HIGH,
}
model = GenerativeModel(
    MODEL_ID,
    safety_settings=safety_settings,
)

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
      print(f"...sending to {MODEL_ID}")
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

def description(exhibit_name, exhibit_subtitle, exhibit_description, extra_text, image_metadata, file_uri):
  prompt = ""
  prompt += f"""This is an image from the Stanford University exhibit entitled "{exhibit_name}".\n"""
  if exhibit_subtitle and not exhibit_subtitle.isspace():
    prompt += f"""Exhibit subtitle: {exhibit_subtitle}.\n"""
  prompt += f"""Exhibit description: {exhibit_description}.\n"""
  if image_metadata and not image_metadata.isspace():
    prompt += f"""Image metadata: {image_metadata}.\n"""
  if extra_text and not extra_text.isspace():
    prompt += f"""Surrounding text:: {extra_text}.\n"""
  prompt += "Please write descriptive alt text (alternative text) for the image. Limit your response to 150 characters or fewer. "
  prompt += """Please avoid starting the description with "This is a photo of..." or "This is an image of...", just say what it is in the image."""
  prompt += """Provide a single option, do not provide multiple options in a list.  Just pick the first one if you think they are all equally valid."""

  if DEBUG:
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
  count = 0
  for row in reader:
    exhibit_name = row[0]
    if ONLY_USE_EXHIBIT_NAME and exhibit_name != ONLY_USE_EXHIBIT_NAME:
      print(f"Skipping {exhibit_name} because it does not match {ONLY_USE_EXHIBIT_NAME}")
      continue
    count += 1
    exhibit_description = row[1]
    exhibit_subtitle = row[2]
    extra_text = row[4]
    image_title = row[5]
    image_caption = row[6]
    image_metadata = image_title + " " + image_caption
    file_uri = f'gs://{BUCKET_NAME}/{DIRECTORY}/{count}.jpg'
    print(f"{count} : {file_uri}")
    writer.writerow([row[0], description(exhibit_name, exhibit_subtitle, exhibit_description, extra_text, image_metadata, file_uri)])
    print()
    if TEST_LIMIT and count >= TEST_LIMIT:
      print(f"Test limit reached: {TEST_LIMIT}")
      break

print(f"Completed {count} rows")
# Get the CSV content as a string
csv_content = csv_buffer.getvalue()
get_blob(OUTPUTFILE).upload_from_string(csv_content, content_type='text/csv')
