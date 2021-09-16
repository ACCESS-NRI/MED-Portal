class VotesController < ApplicationController
  before_action :find_model
  before_action :require_editor

  def create
    if params[:commit].include?("in scope")
      logger.info "IN SCOPE"
      kind = "in-scope"
    elsif params[:commit].include?("out of scope")
      logger.info "OUT OF SCOPE"
      kind = "out-of-scope"
    elsif params[:commit].include?("Just comment")
      logger.info "JUST COMMENTING"
      kind = "comment"
    end

    params = vote_params.merge!(editor_id: current_user.editor.id, kind: kind)

    @vote = @model.votes.build(params)

    if previous_vote = Vote.find_by_model_id_and_editor_id(@model, current_user.editor)
      previous_vote.destroy!
    end

    if @vote.save
      flash[:notice] = "Vote recorded"
      redirect_to model_path(@model)
    else
      flash[:error] = "Comment can't be empty"
      redirect_to model_path(@model)
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:user_id, :comment)
  end

  def find_model
    @model = Paper.find_by_sha(params[:model_id])
  end
end
