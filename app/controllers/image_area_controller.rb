class ImageAreaController < ApplicationController
    # TODO: we probably want auth 
    skip_before_action :verify_authenticity_token, only: [:create]
  
    def create
      # Read the incoming stringified JSON
      data = request.body.read

      # This is a bad hack to get around issues with overwriting the existing "main" window of the Redux store in the viewer.
      # This is all the places "main" is in the data
      # This is the next thing I need to investiage in sul-embed
      json = JSON.parse(data)
      newId = SecureRandom.uuid
      # Replace the "main" key
      if json["windows"].key?("main_1234")
        json["windows"][newId] = json["windows"].delete("main_1234")
        json['windows'][newId]['id'] = newId
      end
      if json["viewers"].key?("main_1234")
        json["viewers"][newId] = json["viewers"].delete("main_1234")
      end
      json['workspace']['windowIds'] = [newId]
      json['workspace']['focusedWindowId'] = newId
      # Convert back to a JSON string
      json_string = JSON.generate(json)
      ### end horrible hack


      # Create a new ImageArea record
      # TODO: update rather than create if the record already exists
      image_area = ImageArea.new(workspace_state: json_string)
  
      if image_area.save
        render json: { status: 'success' }, status: :ok
      else
        render json: { errors: image_area.errors.full_messages }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
  