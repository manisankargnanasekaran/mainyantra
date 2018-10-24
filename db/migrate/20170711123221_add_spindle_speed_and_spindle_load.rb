class AddSpindleSpeedAndSpindleLoad < ActiveRecord::Migration[5.0]
  def change
     add_column :machine_logs, :spindle_speed,:integer
     add_column :machine_logs, :spindle_load,:integer
     add_column :machine_daily_logs, :spindle_speed,:integer
     add_column :machine_daily_logs, :spindle_load,:integer
  end
end
