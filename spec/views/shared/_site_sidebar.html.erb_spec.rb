# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_site_sidebar' do
  subject { rendered }

  it { is_expected.to have_content '' }
end
