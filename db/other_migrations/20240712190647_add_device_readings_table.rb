class AddDeviceReadingsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :device_readings, primary_key: [:device_id, :timestamp_at] do |t|
      # Device ID is a UUID
      t.string :device_id, null: false, limit: 36
      t.datetime :timestamp_at, null: false 
      t.integer :count, null: false, default: 0

      t.timestamps
    end

    add_index :device_readings, :device_id
  end
end
