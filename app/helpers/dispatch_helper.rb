module DispatchHelper

  def initial_activities
    {
      'issues' => {
        'commenters' => {
          'pre-review' => {},
          'review' => {}
        },
        'comments' => [],
        'last_edits' => {},
        'last_comments' => {}
      }
    }
  end

  def parse_payload!(payload)
    return if payload.context.raw_payload.dig('issue').nil?

    @context = payload.context
    @model = Model.where('review_issue_id = ? OR meta_review_issue_id = ?', @context.issue_id, @context.issue_id).first
    return false unless @model
    @model.activities = initial_activities if @model.activities.empty?

    if payload.edited?
      process_edit
    elsif payload.labeled?
      process_labeling
    elsif payload.commented?
      process_comment
    else
      @model.save
    end
  end

  def process_edit
    updated_at = @context.raw_payload.dig('issue', 'updated_at')
    @model.activities['issues']['last_edits'] ||= {}
    @model.activities['issues']['last_edits'][@context.sender] = updated_at

    @model.percent_complete = @model.fraction_check_boxes_complete
    @model.last_activity = updated_at
    @model.save
  end

  # Parse the labels and update model with the new labels.
  def process_labeling
    new_labels = Hash.new
    @context.issue_labels.each do |label|
      new_labels.merge!(label['name'] => label['color'])
    end

    @model.labels = new_labels
    @model.save
  end

  def process_comment
    if @context.issue_title.match(/^\[PRE REVIEW\]:/)
      return if @context.issue_id != @model.meta_review_issue_id
      kind = 'pre-review'
    else
      return if @context.issue_id != @model.review_issue_id
      kind = 'review'
    end

    @model.activities['issues']['last_comments'] ||= {}
    @model.activities['issues']['last_comments'][@context.sender] = @context.comment_created_at
    @model.last_activity = @context.comment_created_at
    @model.activities['issues']['comments'].unshift(
      'author' => @context.sender,
      'comment' => @context.comment_body,
      'commented_at' => @context.comment_created_at,
      'comment_url' => @context.comment_url,
      'kind' => kind
    )

    if @model.activities['issues']['commenters'][kind].has_key?(@context.sender)
      @model.activities['issues']['commenters'][kind][@context.sender] += 1
    else
      @model.activities['issues']['commenters'][kind].merge!(@context.sender => 1)
    end

    # Only keep the last 5 comments
    @model.activities['issues']['comments'] = @model.activities['issues']['comments'].take(5)

    @model.last_activity = @context.comment_created_at
    @model.save
  end
end
