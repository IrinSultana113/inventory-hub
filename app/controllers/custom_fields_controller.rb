class CustomFieldsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory
  before_action :authorize_inventory_owner!
  before_action :set_custom_field, only: %i[edit update destroy]

  def create
    @custom_field = @inventory.custom_fields.build(custom_field_params)
    @custom_field.position = @inventory.custom_fields.maximum(:position).to_i + 1

    if @custom_field.save
      redirect_to @inventory, notice: "Custom field added successfully."
    else
      redirect_to @inventory, alert: @custom_field.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @custom_field.update(custom_field_params)
      redirect_to @inventory, notice: "Custom field updated successfully."
    else
      redirect_to @inventory, alert: @custom_field.errors.full_messages.to_sentence
    end
  end

  def destroy
    @custom_field.destroy
    redirect_to @inventory, notice: "Custom field deleted successfully."
  end

  def manage
    ids = Array(params[:custom_field_ids]).reject(&:blank?)
    fields = @inventory.custom_fields.where(id: ids)

    if fields.empty?
      redirect_to @inventory, alert: "Select at least one custom field."
    elsif params[:action_type] == "edit"
      if fields.count == 1
        redirect_to edit_inventory_custom_field_path(@inventory, fields.first)
      else
        redirect_to @inventory, alert: "Select only one field to edit."
      end
    elsif params[:action_type] == "delete"
      fields.destroy_all
      redirect_to @inventory, notice: "Selected custom fields deleted successfully."
    else
      redirect_to @inventory, alert: "Invalid action."
    end
  end

  private

  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def set_custom_field
    @custom_field = @inventory.custom_fields.find(params[:id])
  end

  def authorize_inventory_owner!
    return if current_user.admin? || @inventory.user_id == current_user.id

    redirect_to inventories_path,
                alert: "You are not authorized to manage custom fields."
  end

  def custom_field_params
    params.require(:custom_field).permit(
      :title,
      :description,
      :field_type,
      :show_in_table,
      :position
    )
  end
end