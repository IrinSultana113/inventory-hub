
class InventoryAccessesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory
  before_action :authorize_owner!

  def create
    add_user_access
  end

  def destroy
    remove_user_access
  end

  private

  def set_inventory
    @inventory = Inventory.find(params[:inventory_id])
  end

  def authorize_owner!
    return if current_user.admin? || @inventory.user_id == current_user.id

    redirect_to inventories_path,
                alert: "You are not authorized to manage access."
  end

  def add_user_access
    user = User.find_by(id: params[:user_id])

    return redirect_with_alert("User not found.") unless user
    return redirect_with_alert("Cannot add this user.") if restricted_user?(user)

    access = @inventory.inventory_accesses.find_or_initialize_by(user: user)

    if access.save
      redirect_to inventory_path(@inventory, anchor: "access"), notice: "Access granted."
    else
      redirect_with_alert(access.errors.full_messages.to_sentence)
    end
  end

  def remove_user_access
    access = @inventory.inventory_accesses.find_by(id: params[:id])

    return redirect_with_alert("Access not found.") unless access

    access.destroy
    redirect_to inventory_path(@inventory, anchor: "access"),
              notice: "Access removed."
  end

  def restricted_user?(user)
    user.blocked? || user.id == current_user.id || user.id == @inventory.user_id
  end

  def redirect_with_alert(message)
    redirect_to inventory_path(@inventory, anchor: "access"),
              alert: message
  end
end
