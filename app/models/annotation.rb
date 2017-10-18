# frozen_string_literal: true

##
# Model for a IIIF Annotation
class Annotation
  attr_reader :id, :text, :target, :motivation
  delegate :content, :language, :format, to: :text
  delegate :xywh, :canvas, :druid, to: :target

  # @param [String] `id`, `text`
  # @param [Annotation::Target] `target`
  # @param [Hash] `options`
  # @option [String] `:language`, `:motivation`
  def initialize(id, text, target, options = {})
    @id = id
    @text = Text.new(text, options[:language] || 'English')
    @target = target
    @motivation = options[:motivation] || 'sc:painting'
  end

  def type
    'oa:Annotation'
  end

  def on
    "#{canvas}#xywh=#{xywh}"
  end

  # Simple model for the text of an annotation
  class Text
    attr_accessor :content, :language, :format
    def initialize(content, language, format = 'text/plain')
      @content = content
      @language = language
      @format = format
    end
  end

  # Simple model for the target of an annotation
  class Target
    attr_accessor :xywh, :canvas, :druid
    def initialize(xywh, canvas, druid)
      @xywh = xywh
      @canvas = canvas
      @druid = druid
    end
  end
end
