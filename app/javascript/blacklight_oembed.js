//= require 'blacklight_oembed/jquery.oembed.js'

import Blacklight from "blacklight-frontend";

Blacklight.onLoad(function() {
  $('[data-embed-url]').oEmbed();
});
