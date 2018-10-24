class FixColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :machine_logs, :last_machine_on, :job_id
    rename_column :machine_logs, :last_machine_off, :total_run_time
    rename_column :machine_logs, :last_reset_time, :cycle_time
    rename_column :machine_logs, :entry_time, :cutting_time
  end
end
