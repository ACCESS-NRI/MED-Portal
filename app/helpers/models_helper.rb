module PapersHelper
  def selected_class(tab_name)
    if controller.action_name == tab_name
      "selected"
    end
  end

  def model_kind(model)
    case model.submission_kind
    when "new"
      "New submission"
    when "resubmission"
      "Resubmission"
    when "new version"
      "New version"
    else
      "Unknown"
    end
  end

  def vote_comment_preview(vote)
    return "No comment" if vote.comment.empty?

    capture do
      concat(content_tag(:span, class: "comment-preview", title: vote.comment) do
        truncate(vote.comment)
      end)
    end
  end

  def model_count_for(user)
    user.models.visible.count
  end

  def scholar_author_tags(authors)
    authors = authors.split(',')
    returned = ""
    authors.each do |author|
      returned << "<meta name=\"citation_author\" content=\"#{author.strip}\">\n"
    end

    returned.html_safe
  end

  def pretty_reviewers(reviewers)
    fragment = []
    reviewers.each do |reviewer|
      fragment << github_link(reviewer) + " (" + reviewer_page_link('all reviews', reviewer) + ")"
    end

    return fragment.join(', ').html_safe
  end

  def reviewer_page_link(link_text, handle)
    link_to link_text, models_by_reviewer_path(handle), title: "All models reviewed by #{handle}"
  end

  def github_link(handle)
    link_to handle, "https://github.com/#{handle.gsub(/^\@/, "")}", title: "GitHub profile for #{handle}", target: "_blank"
  end

  def pretty_authors(authors)
    fragment = []
    authors.each do |author|
      fragment << author_link(author)
    end

    return fragment.join(', ').html_safe
  end

  def author_link(author)
    name = "#{author['given_name']} #{author['middle_name']} #{author['last_name']}".squish
    author_search_link = link_to(name, "/models/by/#{name}".gsub('.', '%2E'))

    if author['orcid']
      orcid_link = link_to author['orcid'], "http://orcid.org/#{author['orcid']}", target: "_blank"
      return "#{author_search_link} (#{orcid_link})"
    else
      return author_search_link
    end
  end

  def pretty_status_badge(model)
    state = model.state.gsub('_', ' ')
    badge_class = model.state.gsub('_', '-')

    state = "published" if state == "accepted"

    return content_tag(:span, state, class: "badge #{badge_class}")
  end

  def time_words(model)
    case model.state
    when "accepted"
      return content_tag(:span, "Published #{time_ago_in_words(model.accepted_at)} ago", class: "time")
    else
      return content_tag(:span, "Submitted #{time_ago_in_words(model.created_at)} ago", class: "time")
    end
  end

  def badge_link(model)
    if model.accepted?
      return model.cross_ref_doi_url
    elsif model.review_pending?
      return model.meta_review_url
    else
      return model.review_url
    end
  end

  def submittor_avatar(model)
    if username = model.submitting_author.github_username
      return "https://github.com/#{username.sub(/^@/, "")}.png"
    else
      return ""
    end
  end

  def submittor_github(model)
    if username = model.submitting_author.github_username
      return "https://github.com/#{username.sub(/^@/, "")}"
    else
      return "https://github.com"
    end
  end

  def formatted_body(model, length=nil)
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter
    ]

    if length
      body = model.body.truncate(length, separator: /\s/)
    else
      body = model.body
    end

    result = pipeline.call(body)
    result[:output].to_s.html_safe
  end

  def model_types
    Rails.application.settings["model_types"]
  end

  def open_invites_for_model(model)
    output = []
    @pending_invitations.each do |invite|
      if invite.model_id == model.id
        output << link_to(image_tag(avatar(invite.editor.login), size: "24x24", class: "avatar", title: "#{invite.editor.full_name} invited #{time_ago_in_words(invite.created_at)} ago"), model.meta_review_url)
      end
    end

    return output.empty? ? "–" : output.join(" • ").html_safe
  end
end
