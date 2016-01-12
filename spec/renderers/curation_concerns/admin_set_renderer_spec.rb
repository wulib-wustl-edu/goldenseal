require 'rails_helper'

describe AdminSetRenderer do
  let(:renderer) { described_class.new(:admin_set, ['Title'], link_path: '/admin_sets/123') }
  describe "#render" do
    subject { renderer.render }
    it { is_expected.to eq "<tr><th>Collection</th>\n<td><ul class='tabular'>" \
         "<li class=\"attribute admin_set\">" \
         "<a href=\"/admin_sets/123\">Title</a></li>\n</ul></td></tr>" }
  end
end
