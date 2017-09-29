# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html). One notable difference is that for this project, semantic versioning is used in reference to user facing experience.

## [Unreleased]

### Added
- Adds basic ~~CSLJSON and~~ bibtex converter using Traject #596 (partially removed in #601)
- Indexes bibliography documents #601
- Enable sidebar in embedded Mirador viewer #598
- Configure a Parker theme (behind a feature flag) #604
- Use citeproc to rendered a sorted bibliography from BibTeX #602
- Enhances bibliography indexing to support relating citation to an exhibit #608
- Add resource index spotlight metadata + benchmarking to BibTeX indexing #617
- Add format type to bib records "Reference" #618
- Add the allowfullscreen attribute to the mirador iframe. #620
- Add BibTeX and formatted bibliography to ingest pipeline #621
- Add flash messages for bibliography resource creation #624
- Add title_full_display for show page #622

### Removed
- Removed old demo environment #487

### Fixed
- Use simplecov string not glob to shut up warnings #597
- Fixes a misspelling in our feature flag #615
- Skip legacy bib service specs (aims to fix flappy Travis) #619

## [1.0.0] - 2017-09-26

We have been in production for a while, but never tagged a release. This starts the first of many releases for Stanford's Exhibits.

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
