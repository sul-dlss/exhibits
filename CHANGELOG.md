# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html). One notable difference is that for this project, semantic versioning is used in reference to user facing experience.

## [Unreleased]

### Added
- Users can now quickly navigate pages in Mirador using a drop down selection #937
### Changed
### Deprecated
### Removed
- Table of contents will not be displayed in the Parker exhibit metadata modal #944
### Fixed
### Security

## [1.9.0] - 2017-11-17

### Added
- Updates Exhibits to Rails 5.1 #873
- Updates Exhibits to Spotlight v1.1.0 #900
- Scrolling in metadata modal body #902
- Add the ability to download Mods metadata #896
- Adds metadata show modal with basic mods rendering #890
- Adds manuscript title link to Page details #848
### Changed
- Single entry in TOC is displayed without show/hide #907
- Refactoring dor traject code #880
- TOC list should be ul/li not line separated #895
- Text title field moved to TOC #891
- Adds frozen_string_literal to all Ruby files #882
### Fixed
- Fixes a bug in TOC show/hide #892
- Fixes a bug where errors stored were sometimes too big #881
- Fixes a bug in indexing collections #909
- Fixes a bug where modal-body height wasn't being calculated #915

## [1.8.0] - 2017-11-13
### Added
- Collapsible table of contents to manuscript metadata section #821,
- A default thumbnail to annotation records #839
- The ability to add a manifest to Mirador instances with a pasted URL #840
- A dedicated sort field for page detail titles #850
- A feature flag for resource type indexing field #852
- The Solr document id of canvases to indexing #851
- "Page_details" rendering added (making annotations visible) #857
- A reference to the parent manifest on canvas objects #862
- A button to toggle/collapse large bibliography sections #866

### Changed
- Marketing and Exhibit documentation links in the site sidebar have been combined #802
- Manuscript lables/titles now use merged "page detail title" #844, #860
- Canvas format has been changed to "page details" from "annotation," etc. #845
- FactoryGirl out for FactoryBot #852
- CSS made generic for all record metadata fields #857
- DOR objects now use traject for indexing #847

### Deprecated
- gdor-indexer #847

### Removed
- Dependency on GDOR-indexer, configuration, etc. #847

### Fixed
- Leaflet-rails and dependencies updated #852
- A bug with the number of arguments in the "resource type" index field #867
- Rubocop has been updated to a more recent version #868
- BlacklightHeatmaps updated to fix map marker zoom bug #859
- Unwrap single note `ul`/`li`s #871
- Bulk updates for many dependecies #868
- Assign unique ids to table of contents sections #863
- Expose document id as passed option instead of instance variable for search results display fix #876

## [1.7.0] - 2017-11-06
## Added
- Support for indexing related annotations identified in the object's IIIF manifest #806
  - _Note: This is being released behind a feature flag for parker-2 only_

## Fixed
- No longer indexing empty annotation strings #813
- Responsive behavior of search results display at small screen resolutions #820
- Updated Spotlight which addressed two user facing issues: #822
  - Prevent throwing an error on the edit screen of a page when an embedded browse category changes its title. projectblacklight/spotlight#1856
  - Truncate exhibit descriptions to deal with responsive issue projectblacklight/spotlight#1853

Full Exhibits Changes: https://github.com/sul-dlss/exhibits/compare/v1.6.0...v1.7.0
Full Spotlight Changes: https://github.com/projectblacklight/spotlight/compare/e9f3771b063ae7f9991c6e6ecf89a634bdd2011a...0929af4e831604ca4aa4847d1efd6782f2ebc34c

## [1.6.0] - 2017-10-30

### Added
- On citation pages, show the cited resources they refereence #692
- Adds the ability to index "Pages/Canvases" as first class objects (non-user facing) #800

### Removed
- "Annotation" model in favor of canvas/pages (non-user facing) #800

## [1.5.0] - 2017-10-25

### Added
- Adds an Annotation data model #765
- Spotlight updates - search fields are configurable now to be turned "off" by default #796
- Adds search_field for TOC, incipit, manuscript title, manuscript number, text_title #792
### Changed
- Updates mod indexing - incipit #782, displayLabel/title #785, collection format #793
### Fixed
- Enforce IIIF manifest availability by using contentMetadata type, fixes indexing performance issue #794
- Spotlight updates - unusable Sir Trevor widgets are not shown to users #796

## [1.4.0] - 2017-10-19
### Added
- Adds Manuscript Number and tableOfContents to MODS indexing #721, #723

### Changed
- Style general notes as an unordered list #742

### Fixed
- Only display the Bibliography section when the async process returns documents #738
- Only add IIIF logos to SDR objects with manifests #745
- Add missing migration from Spotlight related to tagging #753
- Permit up to 1000 hits for JSON API (results in full listing of bibliographies) #700
- Remove media-query to help results thumbnail alignment #735
- Configure sidekiq processes to account for concurrency and nCPUs in stage #711

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
