// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"
import Spotlight from "spotlight"

// Global Blacklight for some Exhibits specific javascript
window.Blacklight = Blacklight

Blacklight.onLoad(function() {
  Spotlight.activate();
});
