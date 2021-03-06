class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :load_schema, :authenticate_user!, :set_mailer_host

  protected

  private

  def load_schema
    Apartment::Tenant.switch('public')
    return unless request.subdomain.present?

    if current_account
      Apartment::Tenant.switch(current_account.subdomain)
    else
      redirect_to root_url(subdomain: false)
    end
  end

  def current_account
    @current_account ||= Account.find_by(subdomain: request.subdomain)
  end

  helper_method :current_account

  def current_project
    @current_project ||= current_account.projects.find_by(params[:id])
  end

  helper_method :current_project


  def set_mailer_host
    subdomain = current_account ? "#{current_account.subdomain}." : ""
    ActionMailer::Base.default_url_options[:host] = "#{subdomain}lvh.me:3000"
  end


  def after_sign_out_path(resource_or_scope)
    subdomain_root_path
    # new_user_session_path
  end

  def after_invite_path_for(resource)
    users_path
  end

  def after_sign_in_path_for(resource_or_scope)
    subdomain_root_path
  end



end
