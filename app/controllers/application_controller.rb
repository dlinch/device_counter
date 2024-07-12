class ApplicationController < ActionController::API

  def store
    DeviceStorage.instance.connection
  end
end
