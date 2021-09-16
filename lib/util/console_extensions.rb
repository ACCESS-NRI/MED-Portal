module Util
  module ConsoleExtensions
    def dat(id)
      return Model.where('review_issue_id = ? OR meta_review_issue_id = ?', id, id).first
    end
  end
end
