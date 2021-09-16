require 'rails_helper'

describe 'models/submitted.html.erb' do
  context 'for submitted models' do
    it "should show the correct number of models" do
      user = create(:user)

      3.times do
        create(:accepted_model, submitting_author: user)
      end

      create(:model, state: "submitted", submitting_author: user)

      assign(:models, Model.submitted.paginate(page: 1, per_page: 10))

      render template: "models/index", formats: :html

      expect(rendered).to have_selector('.model-title', count: 0)
      expect(rendered).to have_content(:visible, "Active Models 1", normalize_ws: true)
    end
  end
end
