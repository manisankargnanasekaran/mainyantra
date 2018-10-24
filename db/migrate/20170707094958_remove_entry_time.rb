class RemoveEntryTime < ActiveRecord::Migration[5.0]
  def change
    remove_column :machine_logs, :cncjob_id
  end
end
