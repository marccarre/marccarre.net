require 'http_accept_language'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_locale

  private
    def set_locale
      if (params[:locale])
        save_locale_in_session
      end

      user_saved = session[:locale].presence
      user_preferred = validate_or_recreate(http_accept_language).user_preferred_languages.presence
      user_compatible = validate_or_recreate(http_accept_language).compatible_language_from(I18n.available_locales).presence
      I18n.locale = user_saved || user_compatible || I18n.default_locale
      logger.info("Selected locale '%s' for %s (available: '%s'; default: '%s'; preferred: '%s'; compatible: '%s'; saved: '%s')." % [I18n.locale, request.remote_ip, I18n.available_locales.join("','"), I18n.default_locale, user_preferred.present? ? user_preferred.join("','"): "''", user_compatible, session[:locale]])
    end

    def save_locale_in_session
      if (I18n.available_locales.include? params[:locale].to_sym)
        new_locale = params[:locale]
        old_locale = session[:locale]
        session[:locale] = new_locale || old_locale
        logger.info("Saved locale '%s' in %s's session (old: '%s'; new: '%s')." % [session[:locale], request.remote_ip, old_locale, new_locale])
      else
        logger.warn("Invalid locale '%s' requested by %s." % [params[:locale], request.remote_ip])
      end
    end

    def validate_or_recreate(http_accept_language)
      if http_accept_language.nil? || http_accept_language.header.blank?
        new_http_accept_language = HttpAcceptLanguage::Parser.new(request.headers['HTTP_ACCEPT_LANGUAGE'])
        logger.info("Created new parser for Accept-Language header: #{new_http_accept_language.as_json} (previously was: #{http_accept_language.as_json}")
        new_http_accept_language
      else 
        http_accept_language
      end
    end
end
