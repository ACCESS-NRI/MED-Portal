require 'rails_helper'

describe Model do
  before(:each) do
    Model.destroy_all
  end

  it "should know how to validate a Git repository address" do
    model = build(:model, :repository_url => 'https://example.com')
    expect { model.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "belongs to the submitting author" do
    association = Model.reflect_on_association(:submitting_author)
    expect(association.macro).to eq(:belongs_to)
  end

  it "has many invitations" do
    association = Model.reflect_on_association(:invitations)
    expect(association.macro).to eq(:has_many)
  end

  it "should know how to parameterize itself properly" do
    model = create(:model)

    expect(model.sha).to eq(model.to_param)
  end

  it "should return it's submitting_author" do
    user = create(:user)
    model = create(:model, user_id: user.id)

    expect(model.submitting_author).to eq(user)
  end

  # Scopes

  it "should return recent" do
    old_model = create(:model, created_at: 2.weeks.ago)
    new_model = create(:model)

    expect(Model.recent).to eq([new_model])
  end

  it "should return only visible models" do
    hidden_model = create(:model, state: "submitted")
    visible_model_1 = create(:accepted_model)
    visible_model_2 = create(:model, state: "superceded")

    expect(Model.visible).to contain_exactly(visible_model_1, visible_model_2)
    assert hidden_model.invisible?
  end

  it "should exclude withdrawn and rejected models" do
    rejected_model = create(:model, state: "rejected")
    withdrawn_model = create(:model, state: "withdrawn")
    model = create(:accepted_model)

    expect(Model.everything).to contain_exactly(model)
    expect(Model.invisible).to contain_exactly(rejected_model, withdrawn_model)
  end

  # GitHub stuff
  it "should know how to return a pretty repo name with owner" do
    model = create(:model, repository_url: "https://github.com/arfon/joss-reviews")

    expect(model.pretty_repository_name).to eq("arfon / joss-reviews")
  end

  it 'should know how to return a pretty DOI' do
    model = create(:model, archive_doi: 'https://doi.org/10.6084/m9.figshare.828487')

    expect(model.pretty_doi).to eq("10.6084/m9.figshare.828487")
  end

  it 'should know how to return a DOI with a full URL' do
    model = create(:model, archive_doi: '10.6084/m9.figshare.828487')

    expect(model.doi_with_url).to eq('https://doi.org/10.6084/m9.figshare.828487')
  end

  it "should bail creating a full DOI URL if if can't figure out what to do" do
    model = create(:model, archive_doi: "http://foobar.com")

    expect(model.doi_with_url).to eq("http://foobar.com")
  end

  it "should know how to generate its review url" do
    model = create(:model, review_issue_id: 999)

    expect(model.review_url).to eq("https://github.com/#{Rails.application.settings["reviews"]}/issues/999")
  end

  describe "#set_editor" do
    it "should update model's editor" do
      model = create(:model)
      editor = create(:editor)

      model.set_editor editor
      expect(model.editor).to eq(editor)
    end

    it "should mark editor's pending invitation as accepted" do
      model = create(:model)
      editor = create(:editor)
      invitation = create(:invitation, :pending, model: model, editor: editor)

      model.set_editor editor
      expect(invitation.reload).to be_accepted
    end

    it "should expire other editor's pending invitations" do
      model = create(:model)
      editor = create(:editor)
      invitation_1 = create(:invitation, :pending, model: model)
      invitation_2 = create(:invitation, :pending, model: model)

      model.set_editor editor
      expect(invitation_1.reload).to be_expired
      expect(invitation_2.reload).to be_expired
    end
  end

  describe "#invite_editor" do
    it "should return false if editor does not exist" do
      expect(create(:model).invite_editor("invalid")).to be false
    end

    it "should email an invitation to the editor" do
      model = create(:model)
      editor = create(:editor)

      expect { model.invite_editor(editor.login) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should create a pending invitation for the invited editor" do
      model = create(:model)
      editor = create(:editor)

      expect(Invitation.exists?(model: model, editor:editor)).to be_falsy
      expect { model.invite_editor(editor.login)}.to change { Invitation.count }.by(1)
      expect(Invitation.pending.exists?(model: model, editor:editor)).to be_truthy
    end
  end

  context "when accepted" do
    it "should know how to generate a PDF URL for Google Scholar" do
      model = create(:accepted_model)

      expect(model.seo_url).to eq('http://joss.theoj.org/models/10.21105/joss.00000')
      expect(model.seo_pdf_url).to eq('http://joss.theoj.org/models/10.21105/joss.00000.pdf')
    end
  end

  context "when not yet accepted" do
    it "should know how to generate a PDF URL for Google Scholar" do
      model = create(:under_review_model)

      expect(model.seo_url).to eq('http://joss.theoj.org/models/48d24b0158528e85ac7706aecd8cddc4')
      expect(model.seo_pdf_url).to eq('http://joss.theoj.org/models/48d24b0158528e85ac7706aecd8cddc4.pdf')
    end
  end

  context "when rejected" do
    it "should change the model state" do
      model = create(:model, state: "submitted")
      model.reject!

      expect(model.state).to eq('rejected')
    end
  end

  context "when starting review" do
    it "should initially change the model state to review_pending" do
      editor = create(:editor, login: "arfon")
      user = create(:user, editor: editor)
      submitting_author = create(:user)

      model = create(:submitted_model_with_sha, submitting_author: submitting_author)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      model.start_meta_review!('arfon', editor)
      expect(model.state).to eq('review_pending')
      expect(model.reload.editor).to be(nil)
      expect(model.reload.eic).to eq(editor)
    end

    it "should then allow for the model to be moved into the under_review state" do
      editor = create(:editor, login: "arfoneditor")
      user = create(:user, editor: editor)
      submitting_author = create(:user)
      model = create(:review_pending_model, submitting_author: submitting_author)
      fake_issue = Object.new
      allow(fake_issue).to receive(:number).and_return(1)
      allow(GITHUB).to receive(:create_issue).and_return(fake_issue)

      model.start_review('arfoneditor', 'bobthereviewer')
      expect(model.state).to eq('under_review')
      expect(model.editor).to eq(editor)
    end
  end

  it "should email the editor AND submitting author when submitted" do
    model = build(:model)

    expect {model.save}.to change { ActionMailer::Base.deliveries.count }.by(2)
  end

  it "should be able to be withdrawn at any time" do
    model = create(:accepted_model)
    assert Model.visible.include?(model)

    model.withdraw!
    refute Model.visible.include?(model)
  end

  describe "#review_body with a single author" do
    let(:author) { create(:user) }
    let(:model) do
      instance = build(:model_with_sha, user_id: author.id, kind: kind)
      instance.save(validate: false)
      instance
    end
    subject { model.review_body("editor_name", "reviewer_name") }

    context "with a model type" do
      let(:kind) { "something_else" }

      it "renders the type-specific checklist" do
        expect {
          subject
        }.to raise_error(
          ActionView::Template::Error,
          %r(Missing partial content/github/_something_else_review_checklist)
        )
      end
    end

    context "with no model type" do
      let(:kind) { nil }
      it { is_expected.to match /Reviewer:/ }
      it { is_expected.to match /JOSS conflict of interest/ }
      it { is_expected.to match /Does the repository contain a plain-text LICENSE file/ }
      it { is_expected.to match /Does installation proceed as outlined/ }
      it { is_expected.to match /Are there automated tests/ }
    end
  end

  describe "#review_body with multiple reviewers" do
    let(:author) { create(:user) }
    let(:model) do
      instance = build(:model, user_id: author.id, kind: kind)
      instance.save(validate: false)
      instance
    end
    subject { model.review_body("editor_name", "mickey,mouse") }

    context "with no model type" do
      let(:kind) { nil }
      it { is_expected.to match /Reviewer:/ }
      it { is_expected.to match /Review checklist for @mickey/ }
      it { is_expected.to match /Review checklist for @mouse/ }
      it { is_expected.to match /\/models\/#{model.sha}/ }
      it { is_expected.to match /#{model.repository_url}/ }
    end
  end

  describe "#meta_review_body" do
    let(:author) { create(:user) }

    let(:model) do
      instance = build(:model_with_sha, user_id: author.id)
      instance.save(validate: false)
      instance
    end

    subject { model.meta_review_body(editor, 'Important Editor') }

    context "with an editor" do
      let(:editor) { "@joss_editor" }

      it "renders text" do
        is_expected.to match /#{model.submitting_author.github_username}/
        is_expected.to match /#{model.submitting_author.name}/
        is_expected.to match /#{Rails.application.settings['reviewers']}/
        is_expected.to match /Important Editor/
      end

      it { is_expected.to match "The author's suggestion for the handling editor is @joss_editor" }
    end

    context "with no editor" do
      let(:editor) { "" }

      it "renders text" do
        is_expected.to match /#{model.submitting_author.github_username}/
        is_expected.to match /#{model.submitting_author.name}/
        is_expected.to match /#{Rails.application.settings['reviewers']}/
      end

      it { is_expected.to match "Currently, there isn't an JOSS editor assigned" }
    end
  end
end
