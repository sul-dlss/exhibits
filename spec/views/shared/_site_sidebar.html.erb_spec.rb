describe 'shared/_site_sidebar', type: :view do
  subject { rendered }

  context 'with a non-admin user' do
    before do
      allow(view).to receive(:can?).with(:create, Spotlight::Exhibit) { false }
      allow(view).to receive(:can?).with(:manage, Spotlight::Site.instance) { false }
      render
    end
    it { is_expected.not_to have_link('Request a new exhibit') }
  end

  context 'with an admin user' do
    before do
      allow(view).to receive(:can?).with(:create, Spotlight::Exhibit) { true }
      allow(view).to receive(:can?).with(:manage, Spotlight::Exhibit) { true }
      allow(view).to receive(:can?).with(:manage, Spotlight::Site.instance) { true }
      render
    end
    it { is_expected.to have_link('Request a new exhibit') }
  end
end
