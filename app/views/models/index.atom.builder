atom_feed do |feed|
  feed.link(rel: 'first', type: "application/atom+xml", href: url_for(format: 'atom', only_path: false))
  url_params = {}
  [:since, :language].each {|p| url_params.merge!(p => params[p]) if params{p}}
  feed.link(rel: 'next', type: "application/atom+xml", href: url_for(params: url_params, format: 'atom', page: @models.current_page + 1, only_path: false)) unless @models.current_page == @models.total_pages
  feed.link(rel: 'previous', type: "application/atom+xml", href: url_for(params: url_params, format: 'atom', page: @models.current_page - 1, only_path: false)) unless @models.current_page == 1
  feed.link(rel: 'last', type: "application/atom+xml", href: url_for(params: url_params, format: 'atom', page: @models.total_pages, only_path: false))
  feed.title(Rails.application.settings["name"])
  feed.updated(@models[0].created_at) if @models.length > 0
  feed.author do |author|
    author.name(Rails.application.settings["name"])
    author.uri(Rails.application.settings["url"])
  end

  @models.each do |model|
    next if model.invisible?
    feed.entry(model, url: model.seo_url) do |entry|
      entry.title(model.title)
      entry.content(type: "application/xml") do |content|
        entry.state(model.state)
        entry.software_version(model.software_version)
        entry.submitted_at(model.created_at)
        if model.accepted?
          entry.issue model.issue
          entry.published_at(model.accepted_at)
          entry.volume model.volume
          entry.year model.year
          entry.page model.page
          entry.authors do |author|
            model.metadata_authors.each_with_index do |a, i|
              sequence = i == 0 ? "first" : "additional"
              author.author("sequence" => sequence) do |auth|
                auth.given_name a['given_name']
                auth.middle_name a['middle_name'] if a['middle_name']
                auth.last_name a['last_name']
                auth.affiliation a['affiliation']
                auth.orcid a['orcid'] if a['orcid']
              end
            end
          end
          entry.doi(model.doi)
          entry.archive_doi(model.clean_archive_doi)
          entry.languages(model.language_tags.join(', '))
          entry.pdf_url(model.seo_pdf_url)
          entry.tags(model.author_tags.join(', '))
        end
      end
    end
  end
end
