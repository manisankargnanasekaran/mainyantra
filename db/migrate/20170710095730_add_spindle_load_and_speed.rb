class AddSpindleLoadAndSpeed < ActiveRecord::Migration[5.0]
  def change
     add_column :machine_daily_logs, :axis_load ,:integer
     add_column :machine_daily_logs, :axis_name,:string
     add_column :machine_logs, :axis_load ,:integer
     add_column :machine_logs, :axis_name,:string
  end
end
