# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Annotation do
  subject(:annotation) { described_class.new(id, text, target, options) }

  let(:id) { 'anno123' }
  let(:text) { 'this is my annotation' }
  let(:target) { Annotation::Target.new(xywh, canvas, druid) }
  let(:options) { { language: 'Latin', motivation: 'sc:commenting' } }
  let(:xywh) { '10,20,30,40' }
  let(:canvas) { 'canvas456' }
  let(:druid) { 'aa111bb2222' }

  it '#id' do
    expect(annotation.id).to eq 'anno123'
  end

  it '#text' do
    expect(annotation.text).to be_an(Annotation::Text)
    expect(annotation.content).to eq 'this is my annotation'
    expect(annotation.language).to eq 'Latin'
    expect(annotation.format).to eq 'text/plain'
  end

  it '#target' do
    expect(annotation.target).to be_an(Annotation::Target)
    expect(annotation.xywh).to eq '10,20,30,40'
    expect(annotation.canvas).to eq 'canvas456'
    expect(annotation.druid).to eq 'aa111bb2222'
  end

  it '#motivation' do
    expect(annotation.motivation).to eq 'sc:commenting'
  end

  it '#type' do
    expect(annotation.type).to eq 'oa:Annotation'
  end

  it '#on' do
    expect(annotation.on).to eq 'canvas456#xywh=10,20,30,40'
  end
end
