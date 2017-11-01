class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :save_access_key
  
  include PublicActivity::StoreController

  #
  # redirect registered users to a profile page
  # of to the admin dashboard if the user is an administrator
  #
  # def after_sign_in_path_for(resource)
  #   resource.role == 'admin' ? admin_dashboard_path : user_path(resource)
  # end

  def authenticate_user!
    super
    Thread.current[:current_user] = current_user
    # raise SecurityError unless current_user.try(:role) == 'admin'
  end

  def styleguide
    authenticate_user!
    render 'layouts/styleguide'
  end

  protected

  def current_customer
    @customer ||= Customer.find_by(path: params[:customer]) if params[:customer]
    @customer ||= Customer.find_by(access_key: session[:access_key]) if session[:access_key]
    @customer
  end
  helper_method :current_customer

  def current_access_key
    params[:access_key] || session[:access_key]
  end
  helper_method :current_access_key

  def save_access_key
    session[:access_key] = params[:access_key] if params.key?(:access_key)
  end

end
