namespace :sync do
  desc "Fix assignees on issues"
  task assignees: :environment do
    # We run this task daily on Heroku
    reviews_repo = Rails.application.settings["reviews"]
    open_issues = GITHUB.list_issues(reviews_repo, state: 'open')

    open_issues.each do |issue|
      editor = issue.body.match(/\*\*Editor:\*\*\s*(@\S*|Pending)/i)[1]
      reviewers = issue.body.match(/Reviewers?:\*\*\s*(.+?)\r?\n/)[1].split(", ") - ["Pending"]
      assignees = reviewers << editor unless editor == "Pending"

      if assignees
        assignees = assignees.collect {|a| a.sub!(/^@/, '')}
        GITHUB.add_assignees(reviews_repo, issue.number, assignees)
      end
    end
  end

  desc "Models cleanup"
  task cleanup_model_branches: :environment do
    reviews_repo = Rails.application.settings["reviews"]
    models_repo = Rails.application.settings["models_repo"]
    # Only check for issues in the last 3 days
    target_time = (Time.now - 3.days).strftime('%Y-%m-%dT%H:%M:%S%z')
    closed_issues = GITHUB.list_issues(reviews_repo, state: 'closed', since: target_time)
    branch_names = GITHUB.branches(models_repo).collect {|b| b.name}

    closed_issues.each do |issue|
      id = "%05d" % issue.number
      wouldbe_branch_name = "#{Rails.application.settings["abbreviation"].downcase}.#{id}"

      if branch_names.include?(wouldbe_branch_name)
        puts "Deleting #{wouldbe_branch_name}"
        GITHUB.delete_branch(models_repo, wouldbe_branch_name)
      end
    end
  end
end
