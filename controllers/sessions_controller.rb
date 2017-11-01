class SessionsController < ApplicationController

  def new
  end

  def create
    customer = Customer.find_by(access_key: params[:access_key])
    if customer
      session[:access_key] = customer.access_key
      redirect_to root_path
    else
      redirect_to sessions_new_path, alert: "Access key is incorrect!"
    end
  end

  def destroy
    session[:access_key] = nil
    redirect_to root_path, notice: "Session closed."
  end
end
