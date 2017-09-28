##
# BibliographyResource model class
class BibliographyResource < Spotlight::Resource
  self.document_builder_class = BibliographyBuilder
end
