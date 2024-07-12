class DeviceStorage
  include Singleton

  attr_reader :connection

  def set(connection = nil)
    connection ||= ActiveSupport::Cache::MemoryStore.new
    @connection = connection
  end
end
