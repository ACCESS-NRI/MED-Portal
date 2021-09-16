require 'rails_helper'

describe 'models/recent.html.erb' do
  context 'for recent models' do
    it "should show the correct number of models" do
      user = create(:user)
      3.times do
        create(:accepted_model, submitting_author: user)
      end

      assign(:models, Model.all.paginate(page: 1, per_page: 10))

      render template: "models/index", formats: :html

      expect(rendered).to have_selector('.model-title', count: 3)
      expect(rendered).to have_content(:visible, "Published Models 3", normalize_ws: true)
    end
  end
end
