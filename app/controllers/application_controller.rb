class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  stale_when_importmap_changes

  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def set_locale
    I18n.locale =
      if user_signed_in?
        current_user.locale.presence_in(%w[en de]) || I18n.default_locale
      else
        I18n.default_locale
      end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end
end