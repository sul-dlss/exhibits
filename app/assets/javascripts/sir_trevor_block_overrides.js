SirTrevor.Blocks.SolrDocumentsEmbed = (function(){
  return SirTrevor.Blocks.SolrDocumentsEmbed.extend({
    item_options: function() {
      return [
        '<label for="<%= formId("maxheight") %>">Maximum height of viewer (in pixels)</label>',
        '<input id="<%= formId("maxheight") %>" type="number" class="form-control" placeholder="600" name="maxheight" />'
      ].join(' ');
    }
  });
})();
