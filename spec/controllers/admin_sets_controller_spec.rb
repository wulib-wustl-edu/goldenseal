require 'rails_helper'

describe AdminSetsController do
  describe "#new" do
    before { sign_in user }
    context "a non-admin" do
      let(:user) { create(:user) }
      it "redirects to home" do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    context "an admin" do
      let(:user) { create(:admin) }
      it "is successful" do
        get :new
        expect(response).to be_successful
      end
    end
  end

  describe "#show" do
    before { sign_in user }
    let(:admin_set) { create(:admin_set) }
    context "a non-admin" do
      let(:user) { create(:user) }
      it "is successful" do
        get :show, id: admin_set
        expect(assigns[:presenter]).to be_kind_of AdminSetPresenter
        expect(response).to be_successful
      end
    end

    context "an admin" do
      let(:user) { create(:admin) }
      it "is successful" do
        get :show, id: admin_set
        expect(response).to be_successful
      end
    end
  end

  describe "#create" do
    before { sign_in user }
    context "a non-admin" do
      let(:user) { create(:user) }
      it "redirects to home" do
        post :create, admin_set: { "title" => "Annie Leibovitz" }
        expect(response).to redirect_to(root_path)
      end
    end

    context "an admin" do
      let(:user) { create(:admin) }
      let(:id) { 'lei' }

      before do
        AdminSet.find(id).destroy(eradicate: true) if AdminSet.exists?(id)
      end

      it "is successful" do
        expect {
          post :create, admin_set: { "title" => "Annie Leibovitz",
                                     "identifier" => id,
                                     "description" => "Pictures by Annie Leibovitz",
                                     "creator" => ["Mark Bussey"],
                                     "contributor" => ["Justin Coyne", "Valerie Maher"],
                                     "subject" => ["Portraiture"],
                                     "publisher" => ["Vanity Fair"],
                                     "language" => ["English"] }
        }.to change { AdminSet.count }.by(1)
        expect(response).to be_redirect

        # :id should be the same as :identifier
        expect { AdminSet.find(id) }.to_not raise_error
      end
    end
  end

  describe "#edit" do
    before { sign_in user }
    let(:admin_set) { create(:admin_set) }

    context "a non-admin" do
      let(:user) { create(:user) }
      it "redirects to home" do
        get :edit, id: admin_set
        expect(response).to be_unauthorized
      end
    end

    context "an admin" do
      let(:user) { create(:admin) }
      it "is successful" do
        get :edit, id: admin_set
        expect(response).to be_successful
      end
    end
  end

  describe "#update" do
    before { sign_in user }
    let(:admin_set) { create(:admin_set) }

    context "a non-admin" do
      let(:user) { create(:user) }
      it "is unauthorized" do
        patch :update, id: admin_set, admin_set: { "title" => "Annie Leibovitz" }
        expect(response).to be_unauthorized
      end
    end

    context "an admin" do
      let(:thumbnail) { create(:file_set) }
      let(:user) { create(:admin) }
      it "is successful" do
        patch :update, id: admin_set, admin_set: { "title" => "Buncha things", thumbnail_id: thumbnail.id }
        expect(assigns[:admin_set].title).to eq 'Buncha things'
        expect(assigns[:admin_set].thumbnail_id).to eq thumbnail.id
        expect(response).to be_redirect
      end
    end
  end

  describe "#confirm_delete" do
    before { sign_in user }
    let(:admin_set) { create(:admin_set) }

    context "a non-admin" do
      let(:user) { create(:user) }
      it "redirects to home" do
        get :confirm_delete, id: admin_set
        expect(response).to redirect_to(root_path)
      end
    end

    context "an admin" do
      let(:user) { create(:admin) }
      it "is successful" do
        get :confirm_delete, id: admin_set
        expect(assigns[:form]).to be_kind_of DeleteAdminSetForm
        expect(response).to be_successful
      end
    end
  end

  describe "#destroy" do
    before { sign_in user }
    let(:admin_set) { create(:admin_set) }

    context "a non-admin" do
      let(:user) { create(:user) }
      it "is unauthorized" do
        delete :destroy, id: admin_set
        expect(response).to be_unauthorized
      end
    end

    context "an admin" do
      let(:user) { create(:admin) }
      it "removes the admin set" do
        expect(DestroyAdminSetJob).to receive(:perform_later).with(admin_set.id, '5')
        delete :destroy, id: admin_set, admin_set: { admin_set_id: '5' }
        expect(flash[:notice]).to eq "test admin set has been queued for removal. This may take several minutes."
        expect(response).to redirect_to root_path
      end
    end
  end
end
