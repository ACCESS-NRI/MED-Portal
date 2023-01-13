class Notifications < ApplicationMailer
  EDITOR_EMAILS = [Rails.application.settings["editor_email"]]

  def submission_email(model)
    @url  = "#{Rails.application.settings["url"]}/models/#{model.sha}"
    @model = model
    mail(to: EDITOR_EMAILS, subject: "New submission: #{model.title}")
  end

  def editor_invite_email(model, editor)
    @model = model
    mail(to: editor.email, subject: "MED-Portal editorial invite: #{model.title}")
  end

  def author_submission_email(model)
    @url  = "#{Rails.application.settings["url"]}/models/#{model.sha}"
    @model = model
    mail(to: model.submitting_author.email, subject: "Thanks for your submission: #{model.title}")
  end

  def editor_weekly_email(editor, pending_issues, assigned_issues, recently_closed_issues)
    @pending_issues = pending_issues
    @assigned_issues = assigned_issues
    @closed_issues = recently_closed_issues
    @editor = editor.login
    mail(to: editor.email, subject: "#{Rails.application.settings["abbreviation"]} weekly editor update for #{editor.login}")
  end

  def editor_scope_email(editor, issues)
    @query_scope_issues = issues
    @editor = editor
    mail(to: editor.email, subject: "[Please review]: #{Rails.application.settings["abbreviation"]} scope check summary")
  end

  def onboarding_invitation_email(onboarding_invitation)
    @onboarding_invitation = onboarding_invitation
    mail(to: onboarding_invitation.email, subject: "Invitation to join the #{Rails.application.settings["abbreviation"]} editorial board")
  end
end
