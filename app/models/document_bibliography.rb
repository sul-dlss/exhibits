##
# A PORO to model individual bibliographies and defines a partial to be rendered
class DocumentBibliography
  def initialize(bib_item)
    @bib_item = bib_item
  end

  def to_html
    @bib_item
  end

  def to_partial_path
    'document_bibliography/bibliography'
  end
end
