##
# BibliographyResource model class
class BibliographyResource < Spotlight::Resource
  self.document_builder_class = BibliographyBuilder

  store :data, accessors: [:bibtex_file]
end
