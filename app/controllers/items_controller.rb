
class ItemsController < ApplicationController
  before_action :set_inventory
  before_action :set_item, only: %i[show edit update destroy]
  before_action :authorize_item_view!, only: %i[index show]
  before_action :authorize_item_write!,
                only: %i[new create edit update destroy bulk_destroy manage]

  def index
    @items = load_items
    @custom_fields = load_custom_fields
  end

  def show
    @custom_field_values = @item.custom_field_values.includes(:custom_field)
  end

  def new
    @item = @inventory.items.build
    build_missing_custom_field_values
  end

  def create
    @item = @inventory.items.build(item_params)
    @item.user = current_user
    @inventory.with_lock do
      sequence_number = @inventory.items.maximum(:sequence_number).to_i + 1

      @item.sequence_number = sequence_number
      if @item.custom_id.blank?
        100.times do
          @item.custom_id = CustomIdGenerator.new(
            @inventory,
            sequence_number: sequence_number
          ).generate

          break unless @inventory.items.exists?(custom_id: @item.custom_id)

          sequence_number += 1
          @item.sequence_number = sequence_number
        end

        if @inventory.items.exists?(custom_id: @item.custom_id)
          @item.errors.add(:custom_id, "could not generate a unique ID")
          raise ActiveRecord::Rollback
       end
      end

      unless @item.save
        raise ActiveRecord::Rollback
      end
    end

    if @item.persisted?
      redirect_to inventory_items_path(@inventory),
                notice: "Item created successfully."
    else
      render_item_form(:new)
    end
  end

  def edit
    build_missing_custom_field_values
  end

  def update
    if @item.update(item_params)
      redirect_to inventory_items_path(@inventory),
                  notice: "Item updated successfully."
    else
      render_item_form(:edit)
    end
  end

  def destroy
    @item.destroy
    redirect_to inventory_items_path(@inventory),
                notice: "Item deleted successfully."
  end

  def bulk_destroy
    items = selected_items

    if items.destroy_all.any?
      redirect_to inventory_items_path(@inventory),
                  notice: "Selected items deleted successfully."
    else
      redirect_to inventory_items_path(@inventory),
                  alert: "Select at least one item."
    end
  end

  def manage
    items = selected_items

    if items.empty?
      redirect_to inventory_items_path(@inventory),
                  alert: "Select an item first."
    elsif params[:action_type] == "edit"
      edit_selected_item(items)
    else
      redirect_to inventory_items_path(@inventory),
                  alert: "Invalid action."
    end
  end

  private

  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def set_item
    @item = @inventory.items.find(params[:id])
  end

  def load_items
    @inventory.items.includes(:user, :custom_field_values)
              .order(created_at: :desc)
  end

  def load_custom_fields
    @inventory.custom_fields.where(show_in_table: true).order(:position)
  end

  def render_item_form(action)
    build_missing_custom_field_values
    render action, status: :unprocessable_entity
  end

  def selected_items
    ids = Array(params[:item_ids]).reject(&:blank?)
    @inventory.items.where(id: ids)
  end

  def edit_selected_item(items)
    return redirect_to inventory_items_path(@inventory),
                       alert: "Select only one item to edit." unless items.one?

    redirect_to edit_inventory_item_path(@inventory, items.first)
  end

  def authorize_item_view!
    return if @inventory.is_public?
    return if current_user && (current_user.admin? || @inventory.user_id == current_user.id)

    redirect_to inventories_path,
                alert: "You are not authorized to view these items."
  end

  def authorize_item_write!
    return if @inventory.can_write_items?(current_user)

    redirect_to inventory_path(@inventory),
                alert: "You are not authorized to manage items."
  end

  def build_missing_custom_field_values
    existing_field_ids = @item.custom_field_values.map(&:custom_field_id)

    @inventory.custom_fields.order(:position).each do |field|
      next if existing_field_ids.include?(field.id)

      @item.custom_field_values.build(custom_field: field)
    end
  end
  def item_params
    params.require(:item).permit(
      :custom_id, custom_field_values_attributes: %i[id custom_field_id value]
    )
  end
end
