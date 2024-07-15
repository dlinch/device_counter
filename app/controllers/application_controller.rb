class ApplicationController < ActionController::API
  def return_if_prod
    head :not_found if Rails.env.production?
  end

  def store
    DeviceStorage.instance.connection
  end
end
