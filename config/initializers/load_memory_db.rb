ActiveSupport::Reloader.to_prepare do
  DeviceStorage.instance.set
end
