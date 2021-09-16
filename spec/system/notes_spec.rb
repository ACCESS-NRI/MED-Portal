require "rails_helper"

feature "Editor notes on models" do
  let(:model) { create(:review_pending_model) }
  let(:editor_user) { create(:user, editor: create(:editor)) }

  scenario "Are not public" do
    visit model_path(model.sha)
    expect(page).to_not have_content("Editor notes")
  end

  scenario "Are not visible to non editors" do
    login_as(create(:user))
    visit model_path(model.sha)
    expect(page).to_not have_content("Editor notes")
  end

  scenario "Are visible to editors" do
    login_as(editor_user)
    visit model_path(model.sha)
    expect(page).to have_content("Editor notes")
  end

  scenario "Are not visible for published models" do
    model = create(:accepted_model)
    login_as(editor_user)
    visit model_path(model.sha)
    expect(page).to_not have_content("Editor notes")
  end

  scenario "Can be created and deleted by editors" do
    login_as(editor_user)
    visit model_path(model.sha)
    fill_in "note_comment", with: "This is a test editor note"
    click_on "Add note"
    expect(page).to have_content("Note saved")

    visit model_path(model.sha)
    within("table#model-notes") do
      expect(page).to have_content("This is a test editor note")
      click_on "Delete note"
    end
    expect(page).to have_content("Note deleted")

    visit model_path(model.sha)
    expect(page).to_not have_content("This is a test editor note")
  end

  scenario "Editors can not delete other editor's notes" do
    note = create(:note)
    login_as(editor_user)
    visit model_path(note.model.sha)

    expect(page).to have_content(note.comment)
    expect(page).to_not have_content("Delete note")
  end
end