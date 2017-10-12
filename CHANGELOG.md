# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html). One notable difference is that for this project, semantic versioning is used in reference to user facing experience.

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.3.0] - 2017-10-12
### Added
- Adds placeholder thumbnails for bibliography documents #651, #698
- Adds a IIIF Drag and Drop badge to Mirador viewer pages #680, #693, #707
- Adds IIIF drag-n-drop icon to search results #681, #732
- Adds support for multiple notes per bibliography resource #605, #685, #715
- Adds View on Zotero site to bibliography show page #539, #670

### Changed
- Updates BibTeX file upload UI #695, #699
- Refactor BibTeX field extraction into Traject Macro #669, #671, #686
- Refactor BibTeX extraction macros #671, #706
- Refactor to use BibTeX prefix for Traject pipeline throughout #712
- Drop the `.json` from our manifest urls (for SDR objects) #710
- Add rails config to `.gitignore` (not added on install) #719
- Updates mirador to v2.6.0 fixes #599, #730
- Configure sidekiq processes on stage to better match prod #711
- Remove the mirador configuration that prevents the Add Slot control #667, #733

### Fixed
- View full reference goes to Reference show page #702, #705
- Updates Spotlight to enable delete email fixes #704, #708
- Does not store a search result to reduce pollution of search session #701, #717

## [1.2.0] - 2017-10-06
### Added
- Adds a Bibliography for a show page with related BibTeX records #660
- Adds exhibit based feature flag pattern for releasing certain features to specific exhibits #674
- Adds the ability for an exhibit editor to add a custom manifest pattern for a given exhibit #668

### Changed
- Adds additional Zotero fields to BibTeX indexing  #664, #675, #682
- Replaces SUL brand logos with SVGs #673
- Generalizes how BibTeX keys are converted to SolrDocument id's #666

### Fixed
- Fixes an issue where home page tags were showing now exhibits #690
- When reindexing BibTeX data, a total count is now shown #655

## [1.1.0] - 2017-10-04

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
- Adds a changelog #627
- Adds accessors and convenience methods for related documents to SolrDocument #653
- Adds Chrome Headless for JavaScript testing #665

### Changed
- Indexes an author for a BibTeX file #628
- Enhances BibTeX indexing to add parent druids #626
- Enhances BibTeX indexing to skip records without a title #637
- Enhances BibTeX indexing to skip records without keywords #644
- Allows a user to upload a BibTeX file to index #639
- Improve BibTeX indexing when BibTeX.parse lexer throws warnings #646
- Improve BibTeX indexing by caching the title #645
- Updates BibTeX fixtures to use minimum set of Zotero fields #656
- Improve BibTeX indexing to add volume and pages to index #633
- Add BibTeX fields for indexing for sorting #657

### Removed
- Removed old demo environment #487
- Removed legacy BibliographyService (never shown to a user in production) #642

### Fixed
- Use simplecov string not glob to shut up warnings #597
- Fixes a misspelling in our feature flag #615
- Skip legacy bib service specs (aims to fix flappy Travis) #619
- Moves Exhibits::Bibliography to Bibliography to fix a production indexing error #630
- Updates Spotlight to fix JavaScript errors and production theme thumbs #643
- Fixes Mirador vertical styling #610
- Only show mirador when a manifest is available #658

### Security
- Updates Blacklight, Spotlight, and Rails #606


## [1.0.0] - 2017-09-26

We have been in production for a while, but never tagged a release. This starts the first of many releases for Stanford's Exhibits.

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
