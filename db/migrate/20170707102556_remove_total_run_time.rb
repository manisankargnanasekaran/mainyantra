class RemoveTotalRunTime < ActiveRecord::Migration[5.0]
  def change
     remove_column :machine_logs, :total_run_time
  end
end
