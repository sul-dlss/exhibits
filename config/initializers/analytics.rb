if Settings.ga
  Spotlight::Engine.config.ga_pkcs12_key_path = Settings.ga.pkcs12_key_path
  Spotlight::Engine.config.ga_email = Settings.ga.email
  Spotlight::Engine.config.ga_web_property_id = Settings.ga.web_property_id
end
