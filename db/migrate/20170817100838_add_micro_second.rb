class AddMicroSecond < ActiveRecord::Migration[5.0]
  def change
    add_column :machine_daily_logs, :run_second ,:integer
    add_column :machine_logs, :run_second ,:integer
  end
end
