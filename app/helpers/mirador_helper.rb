# frozen_string_literal: true

# :nodoc:
module MiradorHelper
  def mirador_options(manifest, canvas, exhibit_slug)
    {
      "mainMenuSettings": {
        "show": false
      },
      "buildPath": '/assets/',
      "saveSession": false,
      "data": [
        {
          "manifestUri": manifest,
          "location": 'Stanford University'
        }
      ],
      "language": 'en',
      "windowObjects": [{
        "loadedManifest": manifest,
        "canvasID": canvas,
        "bottomPanelVisible": false,
        "annotationCreation": false,
        "canvasControls": {
          "annotations": {
            "annotationLayer": true,
            "annotationState": 'on'
          }
        }
      }]
    }.merge(Settings.mirador_options.to_hash)
      .merge(FeatureFlags.for(exhibit_slug)
        .mirador_options?.to_hash)
  end
end
