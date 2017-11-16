# frozen_string_literal: true

##
# Extracted from Purl web application
module RecordHelper
  def mods_display_label(label)
    content_tag(:dt, label.delete(':'))
  end

  # rubocop: disable Rails/OutputSafety
  def mods_display_content(values, delimiter = nil)
    if delimiter
      content_tag(:dd, values.map do |value|
        link_urls_and_email(value) if value.present?
      end.compact.join(delimiter).html_safe)
    else
      Array[values].flatten.map do |value|
        content_tag(:dd, link_urls_and_email(value.to_s).html_safe) if value.present?
      end.join.html_safe
    end
  end
  # rubocop: enable Rails/OutputSafety

  def mods_record_field(field, delimiter = nil)
    return unless field.respond_to?(:label, :values) && field.values.any?(&:present?)
    mods_display_label(field.label) + mods_display_content(field.values, delimiter)
  end

  # rubocop:disable Metrics/LineLength
  def link_urls_and_email(val)
    val = val.dup
    # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    url = %r{(?i)\b(?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\([^\s()<>]+|\([^\s()<>]+\)*\))+(?:\([^\s()<>]+|\([^\s()<>]+\)*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])}i
    # http://www.regular-expressions.info/email.html
    email = %r{[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b}i
    matches = [val.scan(url), val.scan(email)].flatten.uniq
    unless val =~ /<a/ # we'll assume that linking has alraedy occured and we don't want to double link
      matches.each do |match|
        if match =~ email
          val.gsub!(match, "<a href='mailto:#{match}'>#{match}</a>")
        else
          val.gsub!(match, "<a href='#{match}'>#{match}</a>")
        end
      end
    end
    val
  end
  # rubocop:enable Metrics/LineLength
end
