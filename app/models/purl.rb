# frozen_string_literal: true

# Wrapper for working with an object from PURL
class Purl
  include ActiveSupport::Benchmarkable
  attr_reader :druid

  def initialize(druid)
    @druid = druid
  end

  def exists?
    public_xml_record.public_xml.present?
  rescue HTTP::Error
    false
  end

  delegate :items, :collection?, to: :public_xml_record

  def public_xml_record
    @public_xml_record ||= PublicXmlRecord.new(bare_druid)
  end

  def bare_druid
    @bare_druid ||= druid.sub(/^druid:/, '')
  end

  def public_xml
    public_xml_record.public_xml_doc
  end

  def smods_rec
    @smods_rec ||= Stanford::Mods::Record.new.tap do |smods_rec|
      smods_rec.from_str(public_xml_record.mods.to_s)
    end
  end

  def mods_display
    @mods_display ||= ModsDisplay::HTML.new(smods_rec)
  end

  def collections
    @collections ||= public_xml_record.collections.map do |record|
      Purl.new(record.druid)
    end
  end

  def identity_md_obj_label
    public_xml_record.label
  end

  delegate :dor_content_type, to: :public_xml_record

  def logger
    Rails.logger
  end
end
