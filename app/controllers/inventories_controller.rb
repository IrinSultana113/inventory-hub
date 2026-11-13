class InventoriesController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy bulk_destroy custom_id_format update_custom_id_format]
  before_action :set_inventory, only: %i[show edit update destroy custom_id_format update_custom_id_format]
  before_action :authorize_owner!, only: %i[edit update destroy custom_id_format update_custom_id_format]


  def index
    @inventories = Inventory.includes(:user).order(created_at: :desc)
  end

  def show
      @custom_field = @inventory.custom_fields.build
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

  def custom_id_format
  end

  def update_custom_id_format
    if @inventory.update(custom_id_format_params)
      redirect_to custom_id_format_inventory_path(@inventory),
                notice: "Custom ID format updated successfully."
    else
      render :custom_id_format, status: :unprocessable_entity
    end
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
    permitted_params = params.require(:inventory).permit(:title, :description, :category, :is_public, custom_id_format: [:type, :value, :format, :length])

    if permitted_params[:custom_id_format].present?
      permitted_params[:custom_id_format] =
        permitted_params[:custom_id_format].map do |element|
          element.reject { |key, value| value.blank? }
        end
    end
    permitted_params
  end
  
  def custom_id_format_params
    permitted_params = params.require(:inventory).permit(
      custom_id_format: [:type, :value, :format, :length]
    )

    if permitted_params[:custom_id_format].present?
      permitted_params[:custom_id_format] =
        permitted_params[:custom_id_format].map do |element|
          element.reject { |key, value| value.blank? }
        end
    end

    permitted_params
  end
end