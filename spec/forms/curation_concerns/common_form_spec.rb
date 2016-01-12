require 'rails_helper'

describe CurationConcerns::CommonForm do
  let(:raw_attributes) { ActionController::Parameters.new(editor: ['John']) }
  before do
    allow(described_class).to receive(:model_class).and_return(Audio)
  end

  describe ".model_attributes" do
    subject { described_class.model_attributes(raw_attributes) }

    it { is_expected.to eq('editor' => ['John']) }
  end

  describe '.terms' do
    subject { described_class.terms }
    it { is_expected.to eq [:title, :creator, :contributor, :description,
           :subject, :publisher, :source, :language, :representative_id,
           :thumbnail_id, :rights, :files, :visibility_during_embargo,
           :embargo_release_date, :visibility_after_embargo,
           :visibility_during_lease, :lease_expiration_date,
           :visibility_after_lease, :visibility, :admin_set_id, :editor,
           :sponsor, :funder, :researcher, :identifier, :series, :extent,
           :note, :description_standard, :publication_place, :date_issued] }
  end
end

