# Traject+ Usage Notes

Traject is a Ruby library to create lambdas for indexing mappings and transform pipelines. It was originally written for MARC (binary MARC21 or MARCXML) to Solr Documents mappings.

Traject+ are extensions to Traject+, particularly within Spotlight projects, to be able to transform multiple input formats (BibTex, JSON, XML that isn't MARC, etc.) to multiple output formats (Spotlight Ruby resources, Solr, JSON intermediary representations, other).

Notes here will be documenting the current usage of Traject+ within Parker specifically, including examples, explanations, etc.

## Running Traject+ in CLI for Conversion Testing

You can also run traject directly:

```
$ bundle exec traject -c config/traject.rb -c lib/traject/TYPE_config.rb -w SELECTED_WRITER [path to some file]
```

Example:

```bash
$ bundle exec traject -c config/traject.rb -c lib/traject/bibtex_config.rb -w DebugWriter spec/fixtures/bibliography/article.bib
```
