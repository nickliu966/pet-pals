class CommentsController < ApplicationController
  before_action :set_comment, only: [:edit, :update, :destroy]

  def create
    @comment = Comment.new(comment_params)
    @comment.author = current_user
    @post = @comment.post
    @expanded = params[:expanded] == "true"

    respond_to do |format|
      if @comment.save
        @post.reload

        format.html { redirect_back fallback_location: post_path(@comment.post), notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
        format.turbo_stream
      else
        format.html { redirect_back fallback_location: root_url, alert: @comment.errors.full_messages.to_sentence }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize! @comment
  end

  def update
    authorize! @comment

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to post_path(@comment.post), notice: "Comment was successfully updated." }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! @comment

    @post = @comment.post
    @expanded = params[:expanded] == "true"

    @comment.destroy!
    @post.reload

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Comment was successfully destroyed." }
      format.json { head :no_content }
      format.turbo_stream
    end
  end

  private

  def set_comment
    @comment = Comment.find(params.expect(:id))
  end

  def comment_params
    params.expect(comment: [:post_id, :body, :parent_comment_id])
  end
end
