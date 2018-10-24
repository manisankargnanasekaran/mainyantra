class AddTotalRunTime < ActiveRecord::Migration[5.0]
  def change
    add_column :machine_logs, :total_run_time, :integer
   add_column :machine_logs, :total_cutting_time ,:integer
   add_column :machine_logs, :run_time ,:integer
   add_column :machine_logs, :feed_rate ,:integer
   add_column :machine_logs, :cutting_speed,:integer
  end
end
