
class PreferencesController < ApplicationController
  before_action :authenticate_user!

  def update
    preferences = {}

    if params.key?(:theme)
      theme = params[:theme].to_s

      unless %w[light dark].include?(theme)
        return redirect_back(
          fallback_location: root_path,
          alert: I18n.t("preferences.invalid_theme")
        )
      end

      preferences[:theme] = theme
    end

    if params.key?(:locale)
      locale = params[:locale].to_s

      unless %w[en de].include?(locale)
        return redirect_back(
          fallback_location: root_path,
          alert: I18n.t("preferences.invalid_language")
        )
      end

      preferences[:locale] = locale
    end

    if preferences.empty?
      return redirect_back(
        fallback_location: root_path,
        alert: I18n.t("preferences.no_changes")
      )
    end

    if current_user.update(preferences)
        redirect_back(fallback_location: root_path)
      
    else
      redirect_back(
        fallback_location: root_path,
        alert: current_user.errors.full_messages.to_sentence
      )
    end
  end
end
