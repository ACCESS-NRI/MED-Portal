class NotesController < ApplicationController
  before_action :find_model
  before_action :require_editor

  def create
    params = note_params.merge!(editor_id: current_user.editor.id)

    @note = @model.notes.build(params)

    if @note.save
      flash[:notice] = "Note saved"
      redirect_to model_path(@model)
    else
      flash[:error] = "Note can't be empty"
      redirect_to model_path(@model)
    end
  end

  def destroy
    @note = @model.notes.find(params[:id])
    if @note.editor_id == current_user.editor.id
      @note.destroy!
      flash[:notice] = "Note deleted"
    end
    redirect_to model_path(@model)
  end

  private

  def note_params
    params.require(:note).permit(:comment)
  end

  def find_model
    @model = Model.find_by_sha(params[:model_id])
  end
end
