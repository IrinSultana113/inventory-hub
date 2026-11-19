class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])

    @inventories = @user.inventories
                        .public_inventories
                        .order(created_at: :desc)
  end
end