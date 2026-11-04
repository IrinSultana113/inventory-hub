class InventoriesController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy bulk_destroy]
  before_action :set_inventory, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]


  def index
    @inventories = Inventory.includes(:user).order(created_at: :desc)
  end

  def show
  end

  def new
    @inventory = current_user.inventories.build
  end

  def create
    @inventory = current_user.inventories.build(inventory_params)

    if @inventory.save
      redirect_to @inventory, notice: "Inventory created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end
  def update
    if @inventory.update(inventory_params)
      redirect_to @inventory, notice: "Inventory updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @inventory.destroy
    redirect_to inventories_path, notice: "Inventory deleted successfully."
  end
  def bulk_destroy
    selected_ids = params[:inventory_ids] || []

    inventories = current_user.admin? ?
      Inventory.where(id: selected_ids) :
      current_user.inventories.where(id: selected_ids)

    inventories.destroy_all

    redirect_to inventories_path, notice: "Selected inventories deleted successfully."
  end

  private

  def set_inventory
    @inventory = Inventory.find(params[:id])
  end

  def authorize_owner!
    return if current_user.admin? || @inventory.user_id == current_user.id

    redirect_to inventories_path, alert: "You are not authorized to perform this action."
  end

  def inventory_params
    params.require(:inventory).permit(:title, :description, :category)
  end
end