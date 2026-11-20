module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
      @users = User.order(:username)
    end

    def manage
      users = User.where(id: selected_user_ids)

      if users.empty?
        return redirect_to admin_users_path,
                           alert: "Please select at least one user."
      end

      case params[:bulk_action]
      when "block"
        block_users(users)
      when "unblock"
        bulk_update(users, { blocked: false }, "Users unblocked.")
      when "promote"
        promote_users(users)
      when "demote"
        demote_users(users)
      when "delete"
        delete_users(users)
      else
        redirect_to admin_users_path, alert: "Invalid action."
      end
    end

    private

    def require_admin!
      return if current_user&.admin?

      redirect_to root_path,
                  alert: "You are not authorized to access this page."
    end

    def selected_user_ids
      Array(params[:user_ids]).reject(&:blank?)
    end

    def block_users(users)
      eligible_users = users.where.not(id: current_user.id)

      bulk_update(
        eligible_users,
        { blocked: true },
        "Users blocked.",
        "No eligible users selected."
      )
    end

    def promote_users(users)
      eligible_users = users.where(blocked: false)

      bulk_update(
        eligible_users,
        { admin: true },
        "Users promoted to admin.",
        "No active users selected. Blocked users cannot be promoted."
      )
    end

    def demote_users(users)
      remaining_admin = User.where(admin: true)
                        .where.not(id: users.select(:id))
                        .exists?

    unless remaining_admin
      return redirect_to admin_users_path,
        alert: "At least one admin must remain."
    end

    current_user_selected = users.exists?(id: current_user.id)

    redirect_path = current_user_selected ? root_path : admin_users_path
    success_message = current_user_selected ?
      "Your admin role has been removed." :
      "Admin roles removed."

    bulk_update(
      users,
      { admin: false },
      success_message,
      "No users selected.",
      redirect_path
    )
  end

    def delete_users(users)
      eligible_users = users.where.not(id: current_user.id)

      if eligible_users.empty?
        return redirect_to admin_users_path,
                           alert: "You cannot delete your own account from here."
      end

      count = 0

      begin
        User.transaction do
          eligible_users.each do |user|
            user.destroy!
            count += 1
          end
        end

        redirect_to admin_users_path,
                    notice: "#{count} user(s) deleted."
      rescue ActiveRecord::RecordNotDestroyed
        redirect_to admin_users_path,
                    alert: "Could not delete selected users."
      end
    end

    def bulk_update(users, attributes, success_message,
                    empty_message = "No eligible users selected.",
                    redirect_path = admin_users_path)

      if users.empty?
        return redirect_to admin_users_path, alert: empty_message
      end

      User.transaction do
        users.each do |user|
          user.update!(attributes)
        end
      end

      redirect_to redirect_path, notice: success_message
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_users_path,
                  alert: "Could not update selected users."
    end
  end
end