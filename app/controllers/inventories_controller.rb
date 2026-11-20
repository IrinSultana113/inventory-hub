class InventoriesController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy bulk_destroy custom_id_format update_custom_id_format access user_search]
  before_action :set_inventory, only: %i[show edit update destroy custom_id_format update_custom_id_format access user_search]
  before_action :authorize_owner!, only: %i[edit update destroy custom_id_format update_custom_id_format access user_search]


  def index
    @inventories = Inventory.includes(:user).order(created_at: :desc)
  end

  def show
    @custom_field = @inventory.custom_fields.build
    @items = @inventory.items.includes(:user, :custom_field_values)
                     .order(created_at: :desc)
    @custom_fields = @inventory.custom_fields
                             .where(show_in_table: true)
                             .order(:position)
    @inventory_accesses = sorted_inventory_accesses if can_manage_inventory?

    @statistics = build_statistics

    @discussion_posts = @inventory.discussion_posts.includes(:user)
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
      redirect_to inventory_path(@inventory, anchor: "settings"), notice: "Inventory updated successfully."
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
      redirect_to inventory_path(@inventory, anchor: "custom-id"),
                status: :see_other,
                notice: "Custom ID format updated successfully."
    else
      render :custom_id_format, status: :unprocessable_entity
    end
  end

  def access
     @inventory_accesses = sorted_inventory_accesses
  end

  def user_search
    render json: user_search_results
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

  def user_search_results
    return [] if search_query.blank?

    searchable_users.map do |user|
      {
        id: user.id, username: user.username, email: user.email
      }
    end
    end

  def search_query
    params[:q].to_s.strip
  end

  def searchable_users
    query = "%#{ActiveRecord::Base.sanitize_sql_like(search_query)}%"

    User.where(blocked: false)
      .where.not(id: [current_user.id, @inventory.user_id])
      .where("username ILIKE :query OR email ILIKE :query", query: query)
      .order(:username)
      .limit(10)
  end

  def can_manage_inventory?
    current_user&.admin? || @inventory.user_id == current_user&.id
    end

  def sorted_inventory_accesses
    column = params[:sort] == "email" ? "users.email" : "users.username"

    @inventory.inventory_accesses
            .joins(:user)
            .includes(:user)
            .order(column)
  end

    def build_statistics
    fields = @inventory.custom_fields.order(:position).to_a

    numeric_fields = fields.select { |field| field.field_type == "number" }
    string_fields = fields.select { |field| field.field_type == "string" }

    {
      total_items: @inventory.items.count,
      numeric_fields: numeric_field_statistics(numeric_fields),
      string_fields: string_field_statistics(string_fields)
    }
  end

  def numeric_field_statistics(fields)
    values = numeric_values_by_field(fields.map(&:id))

    fields.map do |field|
      numbers = values[field.id] || []

      {
        title: field.title,
        count: numbers.length,
        average: numbers.any? ? (numbers.sum / numbers.length).round(2) : nil,
        minimum: numbers.min,
        maximum: numbers.max,
        range: numbers.any? ? (numbers.max - numbers.min).round(2) : nil
      }
    end
  end

  def numeric_values_by_field(field_ids)
    return {} if field_ids.empty?

    records = CustomFieldValue
      .joins(:item)
      .where(items: { inventory_id: @inventory.id })
      .where(custom_field_id: field_ids)
      .where.not(value: [nil, ""])
      .pluck(:custom_field_id, :value)

    records.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(field_id, value), result|
      number = BigDecimal(value.to_s, exception: false)
      result[field_id] << number if number
    end
  end

  def string_field_statistics(fields)
    counts = string_value_counts(fields.map(&:id))

    fields.map do |field|
      popular_values = counts
        .select { |(field_id, _value), _count| field_id == field.id }
        .map { |(_field_id, value), count| { value: value, count: count } }
        .sort_by { |entry| [-entry[:count], entry[:value].to_s.downcase] }
        .first(5)

      {
        title: field.title,
        values: popular_values
      }
    end
  end

  def string_value_counts(field_ids)
    return {} if field_ids.empty?

    CustomFieldValue
      .joins(:item)
      .where(items: { inventory_id: @inventory.id })
      .where(custom_field_id: field_ids)
      .where.not(value: [nil, ""])
      .group(:custom_field_id, :value)
      .count
  end
end