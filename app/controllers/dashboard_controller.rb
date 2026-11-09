class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = load_categories
    @my_inventories = filtered_inventories
    @my_inventories = sorted_inventories(@my_inventories)
  end

  private

  def load_categories
    current_user.inventories.distinct.order(:category).pluck(:category)
  end

  def filtered_inventories
    inventories = current_user.inventories

    if @categories.include?(params[:category])
      inventories = inventories.where(category: params[:category])
    end

    inventories
  end

  def sorted_inventories(inventories)
    sort_column = %w[title created_at].include?(params[:sort]) ?
      params[:sort] : "created_at"

    sort_direction = params[:direction] == "asc" ? :asc : :desc

    inventories.order(sort_column => sort_direction)
  end
end