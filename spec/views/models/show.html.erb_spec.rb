require 'rails_helper'

describe 'models/show.html.erb' do
  before(:each) do
    allow(Repository).to receive(:editors).and_return ["@user1", "@user2"]
  end

  context 'rendering model status partial' do
    it "displays correctly for submitted model" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      model = create(:model, state: "submitted", submitting_author: user)
      assign(:model, model)

      render template: "models/show", formats: :html

      expect(rendered).to have_content(:visible, "but the review hasn't started.", normalize_ws: true)
    end

    it "displays correctly for accepted model" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      model = create(:accepted_model)
      assign(:model, model)

      render template: "models/show", formats: :html

      # Paper metadata
      # FIXME - these tests seem to be timezone sensitive??? i.e. can fail depending
      # upon the time of day when running the tests...
      expect(rendered).to have_content "Submitted #{Time.now.strftime('%d %B %Y')}"
      expect(rendered).to have_content "Published #{Time.now.strftime('%d %B %Y')}"
      expect(rendered).to have_content "Ruby"
      expect(rendered).to have_content "Editor: @arfon (all models)"
      expect(rendered).to have_content "Reviewers: @jim (all reviews), @jane (all reviews)"
      expect(rendered).to have_content "Walt Elias Disney"
    end

    it "has the correct Google Scholar tags" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      model = create(:accepted_model)
      assign(:model, model)

      render template: "models/show", formats: :html

      # Paper metadata
      expect(rendered).to have_title("The Journal of Open Source Software: #{model.scholar_title}")

      expect(rendered).to have_css("meta[name='citation_title']", visible: false)
      expect(rendered).to have_css("meta[content='#{model.scholar_title}']", visible: false)

      expect(rendered).to have_css("meta[name='citation_author']", visible: false)
      expect(rendered).to have_css("meta[content='Mickey Mouse']", visible: false)
      expect(rendered).to have_css("meta[content='Walt Elias Disney']", visible: false)

      expect(rendered).to have_css("meta[name='citation_publication_date']", visible: false)
      expect(rendered).to have_css("meta[content='#{model.accepted_at.strftime('%Y/%m/%d')}']", visible: false)

      expect(rendered).to have_css("meta[name='citation_journal_title']", visible: false)
      expect(rendered).to have_css("meta[content='#{Rails.application.settings['name']}']", visible: false)


      expect(rendered).to have_css("meta[name='citation_pdf_url']", visible: false)
      expect(rendered).to have_css("meta[content='#{model.seo_pdf_url}']", visible: false)

      expect(rendered).to have_css("meta[name='citation_doi']", visible: false)
      expect(rendered).to have_css("meta[content='10.21105/joss.00000']", visible: false)

      expect(rendered).to have_css("meta[name='citation_issn']", visible: false)
      expect(rendered).to have_css("meta[content='#{Rails.application.settings['issn']}']", visible: false)
    end
  end

  context 'rendering admin partial' do
    it "displays buttons when there's no GitHub issue" do
      user = create(:user, admin: true)
      author = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      model = create(:model, state: "submitted", review_issue_id: nil, submitting_author: author)
      assign(:model, model)

      render template: "models/show", formats: :html

      expect(rendered).to have_selector("input[type=submit][value='Reject model']")
    end

    it "shows the withdraw button to model owners" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      model = create(:model, state: "submitted", submitting_author: user)
      assign(:model, model)

      render template: "models/show", formats: :html
      expect(rendered).to have_selector("input[type=submit][value='Withdraw model']")
    end

    it "shows the withdraw button to admins" do
      user = create(:user, admin: true)
      editor = create(:editor, user: user)
      author = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      model = create(:model, state: "submitted", submitting_author: author)
      assign(:model, model)

      render template: "models/show", formats: :html
      expect(rendered).to have_selector("input[type=submit][value='Withdraw model']")
      expect(rendered).to have_content(author.email)
    end

    it "doesn't displays buttons when there's a GitHub issue" do
      user = create(:user, admin: true)
      author = create(:user)

      allow(view).to receive_message_chain(:current_user).and_return(user)
      allow(view).to receive_message_chain(:current_editor).and_return(user)

      model = create(:resubmission_model, state: "submitted", review_issue_id: 123, submitting_author: author)
      assign(:model, model)

      render template: "models/show", formats: :html

      expect(rendered).to have_content "Paper review"
      expect(rendered).to have_content "Resubmission"
    end

    it "shows the takedown notice for a retracted model" do
      user = create(:user)
      allow(view).to receive_message_chain(:current_user).and_return(user)

      model = create(:retracted_model, retraction_notice: "Reasons for retraction")
      assign(:model, model)

      render template: "models/show", formats: :html
      expect(rendered).to have_content("Reasons for retraction")
    end
  end
end
