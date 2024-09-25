if Settings.ga
  Spotlight::Engine.config.ga_json_key_path = Settings.ga.json_key_path
  Spotlight::Engine.config.ga_web_property_id = Settings.ga.web_property_id
  Spotlight::Engine.config.ga_property_id = Settings.ga.property_id
  Spotlight::Engine.config.ga_debug_mode = Settings.analytics_debug
  Spotlight::Engine.config.ga_page_analytics_options = Spotlight::Engine.config.ga_analytics_options.merge(limit: 5)
  Spotlight::Engine.config.ga_search_analytics_options = Spotlight::Engine.config.ga_analytics_options.merge(limit: 11)
end
