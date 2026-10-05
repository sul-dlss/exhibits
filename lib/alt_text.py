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

#################
# CONFIGURATION
# Define project information
BASE_IMAGE_URL = "https://exhibits.stanford.edu"
PROJECT_ID = "sul-ai-sandbox"  # @param {type:"string"}
LOCATION = "us-central1"  # @param {type:"string"}
BUCKET_NAME = "cloud-ai-platform-e215f7f7-a526-4a66-902d-eb69384ef0c4"
DIRECTORY = "exhibits-alt-text/pilot-2" # base directory for the images and CSV file in the google bucket
INPUTFILE = f'{DIRECTORY}/images.csv' # location of the input CSV file in the google bucket
IMAGES_FOLDER = f'{DIRECTORY}/images' # location of the images in the google bucket
OUTPUT_FOLDER = f'{DIRECTORY}/output' # location of the where to write the output CSV files in the google bucket
LOGFILE = 'log.txt' # location of the log file in Vertex AI
MODEL_ID = 'gemini-2.0-flash'
# other options (see Google AI Studio for more):
# "gemini-2.5-pro-preview-03-25"
# "gemini-1.5-pro"
TEST_LIMIT = None # limit the number of images to process for testing, set to None to process all
DEBUG = False # set to True to NOT send images to AI (test script only)
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
#################


#################
# SHARED FUNCTIONS
# Send Google Cloud Storage Document to Vertex AI
def generate_description(
    prompt: str,
    file_uri: str,
    exhibit_name: str,
    page_title: str,
    image_url: str,
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
      response = model.generate_content(contents)#, generation_config=generation_config)

      return response.text.rstrip()
    except Exception as e:
        # Handle any other unforeseen errors
        error = f"**** ERROR: {e}. Exhibit: {exhibit_name}.  Page: {page_title}.  Image: {image_url}"
        print(error, file = f)
        print("", file = f)
        print(error)

def full_image_url(image_url):
  # Convert the image_url to a full URL if it not already a full URL
  if image_url.startswith("https://"):
    return image_url
  else:
    return f"{BASE_IMAGE_URL}{image_url}"


def get_blob(blob_name):
  client = storage.Client()
  bucket = client.bucket(BUCKET_NAME)
  return bucket.blob(blob_name)


def generate_prompt(exhibit_name, exhibit_subtitle, exhibit_description, extra_text, image_metadata):
  prompt = ""
  prompt += f"""This is an image from the Stanford University exhibit entitled "{exhibit_name}".\n"""
  if exhibit_subtitle and not exhibit_subtitle.isspace():
    prompt += f"""Exhibit subtitle: {exhibit_subtitle.strip()}.\n"""
  prompt += f"""Exhibit description: {exhibit_description.strip()}.\n"""
  if image_metadata and not image_metadata.isspace() and not '.jpg' in image_metadata:
    prompt += f"""Image metadata: {image_metadata.strip()}.\n"""
  if extra_text and not extra_text.isspace():
    prompt += f"""Surrounding text:: {extra_text.strip()}.\n"""
  prompt += "Please write descriptive alt text (alternative text) for the image. Limit your response to 150 characters or fewer. "
  prompt += """Please avoid starting the description with "This is a photo of..." or "This is an image of...", just say what it is in the image."""
  prompt += """Provide a single option, do not provide multiple options in a list.  Just pick the first one if you think they are all equally valid."""
  return prompt


def output_csv_header():
  return ["Exhibit", "Page Title", "Page URL", "Image URL", "Bucket Image Filename", f"AI Generated Description ({MODEL_ID})", "Prompt",
          'AI description NOT useful and new, accurate alt text must be created (mark with an "X" if so)',
          'AI description useful AS IS (mark with an "X" if so)',
          'AI description partially useful with EDITS NEEDED (mark with an "X" if so)',
          "New OR edited description (when needed)",
          'Image is DECORATIVE, no description required (mark with an "X" if so)']


def output_csv_filename(exhibit_name):
  fileslug = exhibit_name.replace(" ", "_").replace("/", "_").replace(":", "_").replace("'", "_").replace('"', "_").replace("?", "_").replace(",", "_").replace("&", "_")
  return f"{OUTPUT_FOLDER}/{fileslug}.csv"


def write_output_csv_file(exhibit_name, csv_buffer):
  output_filename = output_csv_filename(exhibit_name)
  print(f"Writing {exhibit_name} to {output_filename}")
  csv_content = csv_buffer.getvalue()
  get_blob(output_filename).upload_from_string(csv_content, content_type='text/csv')
#################

#################
# Main script
with get_blob(INPUTFILE).open() as csvfile:
  with open(LOGFILE, "w") as f:
    output = f"Running {MODEL_ID} on {INPUTFILE} with {BUCKET_NAME}/{IMAGES_FOLDER}"
    print(output, file = f)
    print("", file = f)
    print(output)

    reader = csv.reader(csvfile)

    next(reader) # skip headers
    previous_exhibit_name = None

    count = 0
    csv_buffer = StringIO()

    for row in reader:
      exhibit_name = row[0]

      if ONLY_USE_EXHIBIT_NAME and exhibit_name != ONLY_USE_EXHIBIT_NAME:
        print(f"Skipping {exhibit_name} because it does not match {ONLY_USE_EXHIBIT_NAME}")
        continue

      # Check if the exhibit name has changed
      if exhibit_name != previous_exhibit_name:
        if previous_exhibit_name is not None:
          # Write out the previous CSV file if this is the first exhibit overall
          write_output_csv_file(previous_exhibit_name, csv_buffer)

        # Create a new CSV file
        previous_exhibit_name = exhibit_name
        print()
        print('**********************************', file = f)
        print(exhibit_name, file = f)
        print("", file = f)
        print(exhibit_name)
        # Create a new StringIO buffer for the new exhibit
        csv_buffer = StringIO()
        writer = csv.writer(csv_buffer)
        writer.writerow(output_csv_header())

      count += 1
      exhibit_description = row[1]
      exhibit_subtitle = row[2]
      page_title = row[3]
      extra_text = row[4]
      image_title = row[5]
      image_caption = row[6]
      # exhibit_slug = row[7]
      # page_slug = row[8]
      page_url = row[9]
      image_url = full_image_url(row[10])
      image_metadata = image_title + " " + image_caption
      bucket_image_url = row[11]
      file_uri = f'gs://{BUCKET_NAME}/{IMAGES_FOLDER}/{bucket_image_url}'

      log = f"Row {count} : {exhibit_name} : {bucket_image_url} : {file_uri}"
      print(log, file = f)
      print(f"Row {count}")

      prompt = generate_prompt(exhibit_name, exhibit_subtitle, exhibit_description, extra_text, image_metadata)

      print(f"Prompt: {prompt}", file = f)
      print("", file = f)

      if DEBUG:
        description = "Description from AI would go here"
      else:
        description = generate_description(prompt, file_uri, exhibit_name, page_title, image_url)

      writer.writerow([exhibit_name, page_title, page_url, image_url, bucket_image_url, description, prompt])

      if TEST_LIMIT and count >= TEST_LIMIT:
        print(f"Test limit reached: {TEST_LIMIT}")
        break

  # write out the last exhibit csv file
  write_output_csv_file(exhibit_name, csv_buffer)

  print(f"Completed {count} rows")
  #################
