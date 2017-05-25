require 'rails_helper'

describe Viewer do
  it 'belongs to an exhibit' do
    expect(described_class.reflect_on_association(:exhibit).macro).to eq :belongs_to
  end
end
