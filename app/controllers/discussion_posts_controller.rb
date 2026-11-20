
class DiscussionPostsController < ApplicationController
  before_action :set_inventory

  def index
    @posts = new_posts
    render json: @posts.map { |post| format_post(post) }
  end

  def create
    return redirect_to_login unless user_signed_in?

    @post = @inventory.discussion_posts.build(post_params)
    @post.user = current_user

    if @post.save
      redirect_to_discussion
    else
      redirect_to_discussion(alert: @post.errors.full_messages.to_sentence)
    end
  end

  private

  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def new_posts
    @inventory.discussion_posts
              .includes(:user)
              .where("discussion_posts.id > ?", params[:after_id].to_i)
  end

  def format_post(post)
    {
      id: post.id,
      username: post.user.username,
      user_id: post.user.id,
      body: helpers.markdown_to_html(post.body),
      created_at: post.created_at.strftime("%d %b %Y, %I:%M %p")
    }
  end

  def post_params
    params.require(:discussion_post).permit(:body)
  end

  def redirect_to_login
    redirect_to new_user_session_path,
                alert: "Please sign in to post a comment."
  end

  def redirect_to_discussion(notice: nil, alert: nil)
    redirect_to inventory_path(@inventory, anchor: "discussion"),
                notice: notice,
                alert: alert,
                status: :see_other
  end
end
