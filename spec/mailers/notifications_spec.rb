require "rails_helper"

describe Notifications, type: :mailer do
  it "should include the idea text in the body" do
    model = create(:model, title: "Nice model!")
    mail = Notifications.submission_email(model)

    expect(mail.subject).to match /Nice model/
  end

  it "should tell the submitting author to chill out" do
    model = create(:model, title: "Nice model!")
    mail = Notifications.author_submission_email(model)

    expect(mail.text_part.body).to match /is currently awaiting triage by our managing editor/
  end
end
