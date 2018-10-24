class AddMoreFieldToMachineDailyLog < ActiveRecord::Migration[5.0]
  def change
   add_column :machine_daily_logs, :total_run_time, :integer
   add_column :machine_daily_logs, :total_cutting_time ,:integer
   add_column :machine_daily_logs, :run_time ,:integer
  end
end
