
ALT TEXT Exhibits AI Experiment

# Intro

This document describes the experiment code to export images and metadata from specified Stanford Exhibits, and then the images to Gemini with a specific prompt to have alt text generated and exported to a CSV file.

See https://github.com/sul-dlss/exhibits/issues/2816
All code is in https://github.com/sul-dlss/exhibits/pull/2901

# How to Run

1. Create a txt file with a list of exhibit name titles, one per line, with no header.
2. Place the exhibits.txt file on the exhibits prod server, in the currently deployed folder location, in the tmp folder (e.g. ~/exhibits/current/tmp/exhibits.txt)
3. Move rake task defined in https://github.com/sul-dlss/exhibits/blob/alt-text-ai/lib/tasks/alt_text.rake to exhibits prod server or just copy and paste the code into a Rails console on the prod server.
4. Run the rake task code or code pasted into the rails console: RAILS_ENV=production rake alt_text:export_images
5. An output file with images URLs will be created in ~/exhibits/curent/tmp/images.csv
6. All images referenced in the images.csv file should be exported to a folder called “tmp/images” on the server
7. SCP the images.csv and images folder onto your laptop from the server.
8. Use GCP Console at https://console.cloud.google.com/storage/browser/  and copy all of the images to the google cloud platform bucket, where the AI script can find them.  We are currently using this bucket: “cloud-ai-platform-e215f7f7-a526-4a66-902d-eb69384ef0c4” in a sub-folder called “exhibits-alt-text” and then another sub-folder, like “pilot-2”.  This bucket is part of the GCP project “sul-ai-sandbox”.  All of these locations can be configured when you run the python script below in GCP that sends the images to the AI model.
9. Go to Vertex AI Collab Notebooks in GCP to run the script from https://github.com/sul-dlss/exhibits/blob/alt-text-ai/lib/alt_text.py   If you don’t already have the script in a notebook, create a new one and paste in the python code.  Make sure you configure the correct GCP project name, bucket name, folders, and input filenames at the top of the script.
10. For testing purposes, you can limit the number of images sent, specify it to run only a specific exhibit and/or have it log all of the prompts in the output.
11. Start the script running and watch the output.
12. When complete, multiple output CSV files will be generated in the OUTPUTFOLDER location specified at the top of the script. You can download these file from the GCP bucket (one per exhibit).
13. A log file will be generated in the "content" folder in VertexAI where it can be viewed.  Click the folder icon in the sidebar and look in the content folder.
