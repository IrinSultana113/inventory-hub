
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Inventories created by the logged-in user
    owned = current_user.inventories

    # Inventories where the user has write permission
    writable = writable_inventories

    @owned_categories = owned.distinct.order(:category).pluck(:category)
    @writable_categories = writable.distinct.order(:category).pluck(:category)

    @my_inventories = filter_and_sort(
      owned,
      "owned",
      @owned_categories
    )

    @writable_inventories = filter_and_sort(
      writable,
      "writable",
      @writable_categories
    )
  end

  private

  def writable_inventories
    if current_user.admin?
      Inventory.where.not(user_id: current_user.id)
    else
      accessible_ids = InventoryAccess
        .where(user_id: current_user.id)
        .select(:inventory_id)

      Inventory
        .where(is_public: true)
        .or(Inventory.where(id: accessible_ids))
        .where.not(user_id: current_user.id)
    end
  end

  def filter_and_sort(inventories, prefix, categories)
    category = params["#{prefix}_category"]
    if categories.include?(category)
      inventories = inventories.where(category: category)
    end

    sort_column = %w[title created_at].include?(params["#{prefix}_sort"]) ?
      params["#{prefix}_sort"] : "created_at"

    sort_direction = params["#{prefix}_direction"] == "asc" ? :asc : :desc

    inventories.order(sort_column => sort_direction)
  end
end
