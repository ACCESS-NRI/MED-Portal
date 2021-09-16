require 'rails_helper'

RSpec.describe "models/new", type: :view do
  let(:model_types) { [] }
  let!(:model) { assign(:model, build(:model)) }

  before(:each) do
    allow(Repository).to receive(:editors).and_return %w(@user1 @user2 @user3)
  end

  around(:each) do |example|
    setting = Rails.application.settings["model_types"]
    Rails.application.settings["model_types"] = model_types
    example.run
    Rails.application.settings["model_types"] = setting
  end

  context "with multiple model types" do
    let(:model_types) { %w(type1 type2 type3) }

    it "renders the new model form" do
      render

      assert_select "form[action=?][method=?]", models_path, "post" do
        assert_select "select#model_kind[name=?]", "model[kind]"
        assert_select "input#model_title[name=?]", "model[title]"
        assert_select "input#model_repository_url[name=?]", "model[repository_url]"
        assert_select "input#model_software_version[name=?]", "model[software_version]"
        assert_select "select#model_suggested_editor[name=?]", "model[suggested_editor]"
        assert_select "textarea#model_body[name=?]", "model[body]"
        assert_select "input#author-check"
        assert_select "input#coc-check"
      end
    end
  end

  context "with no model types" do
    let(:model_types) { [] }

    it "renders the new model form" do
      render

      assert_select "form[action=?][method=?]", models_path, "post" do
        assert_select "select#model_kind", false
        assert_select "input#model_title[name=?]", "model[title]"
        assert_select "input#model_repository_url[name=?]", "model[repository_url]"
        assert_select "input#model_software_version[name=?]", "model[software_version]"
        assert_select "select#model_suggested_editor[name=?]", "model[suggested_editor]"
        assert_select "textarea#model_body[name=?]", "model[body]"
        assert_select "input#author-check"
        assert_select "input#coc-check"
      end
    end
  end
end
