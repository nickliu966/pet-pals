class LikesController < ApplicationController
  before_action :set_like, only: [ :destroy ]

  def create
    @like = Like.new(like_params)
    @like.fan = current_user
    @post = @like.post

    respond_to do |format|
      if @like.save
        @post.reload

        format.html { redirect_back fallback_location: post_path(@like.post), notice: "Like was successfully created." }
        format.json { render :show, status: :created, location: @like }
        format.turbo_stream
      else
        format.html { redirect_back fallback_location: root_url, alert: @like.errors.full_messages.to_sentence }
        format.json { render json: @like.errors, status: :unprocessable_entity }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = @like.post

    @like.destroy!
    @post.reload

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Like was successfully destroyed." }
      format.json { head :no_content }
      format.turbo_stream
    end
  end

  private

  def set_like
    @like = current_user.likes.find(params.fetch(:id))
  end

  def like_params
    params.expect(like: [ :post_id ])
  end
end
