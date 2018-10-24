class RenameLastMachineOn < ActiveRecord::Migration[5.0]
  def change
    rename_column :machine_daily_logs, :last_machine_on, :job_id
  end
end
