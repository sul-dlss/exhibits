require 'bibtex'
require 'citeproc'

# Bibliography represents a bibliography that can be rendered as HTML
# using BibTeX and CiteProc
class Bibliography
  attr_reader :bibliography

  # @param [BibTeX::Bibliography|Pathname|String] `bibliography`
  def initialize(bibliography)
    @bibliography = case bibliography
                    when Pathname
                      BibTeX.parse(bibliography.read)
                    when String
                      BibTeX.parse(bibliography)
                    when BibTeX::Bibliography
                      bibliography
                    else
                      raise ArgumentError, 'Unsupported type'
                    end
    remove_latex_markup!
  end

  def to_html
    render
  end

  private

  # Renders a *sorted* bibliography
  def render(format = 'html')
    cp = CiteProc::Processor.new style: 'chicago-author-date', format: format
    cp.import bibliography.to_citeproc
    cp.bibliography.join
  end

  # Our bibliography has elements that have LaTeX markup in them, namely {}'s and
  # \textit{}, etc. This method removes that markup. Note that the `.convert :latex`
  # function provided by the bibtex-ruby gem is trivial and doesn't handle the majority
  # of cases.
  def remove_latex_markup!
    @bibliography.each do |item|
      item.title = strip_latex(item.title)
      item.booktitle = strip_latex(item.booktitle)
      # TODO: do we need to call strip_latex on other fields?
    end
    @bibliography = @bibliography.convert :latex # cleans up the remaining {}'s in other fields
  end

  # LaTeX.decode from the latex-decode gem doesn't catch nested cases like
  # `\textit{my {Capitalized Title}}`. So we implement a very simple aggressive
  # removal of LaTeX markup
  def strip_latex(latex)
    return if latex.blank?
    s = latex.dup
    s.gsub!(/\\textit/i, '')
    s.gsub!(/\\textbf/i, '')
    s.gsub!(/[\{\}]/, '')
    s.gsub!(/\\\s*&/, '')
    s
  end
end
