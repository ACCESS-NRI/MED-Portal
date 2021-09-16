json.title @model.title
json.state @model.state
json.submitted_at @model.created_at
if @model.published?
  json.doi @model.doi
  json.published_at @model.accepted_at
  json.volume @model.volume
  json.issue @model.issue
  json.year @model.year
  json.page @model.page
  json.authors @model.metadata_authors
  json.editor @model.metadata_editor
  if @model.editor
    json.editor_name @model.editor.full_name
    json.editor_url @model.editor.url if @model.editor.url
    json.editor_orcid @model.editor.orcid
  end
  json.reviewers @model.metadata_reviewers
  json.languages @model.language_tags.join(', ')
  json.tags @model.author_tags.join(', ')
  json.software_repository @model.repository_url
  json.model_review @model.review_url
  json.pdf_url @model.seo_pdf_url
  json.software_archive @model.clean_archive_doi
end
