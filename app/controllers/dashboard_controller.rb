class DashboardController < ApplicationController
  before_action :authenticate_user!

def index
  @categories = current_user.inventories.distinct.order(:category).pluck(:category)

  @my_inventories = current_user.inventories

  if @categories.include?(params[:category])
    @my_inventories = @my_inventories.where(category: params[:category])
  end

  sort_column = %w[title created_at].include?(params[:sort]) ? params[:sort] : "created_at"
  sort_direction = params[:direction] == "asc" ? :asc : :desc

  @my_inventories = @my_inventories.order(sort_column => sort_direction)
end
end