require 'rails_helper'

describe Audio do
  let(:document) { described_class.new }

  describe "tei" do
    subject { document.tei }
    it { is_expected.to be_nil }
  end
end
