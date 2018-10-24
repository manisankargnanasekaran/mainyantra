class AddEntryTimeToMachineLog < ActiveRecord::Migration[5.0]
  def change
    add_column :machine_logs, :entry_time, :string
  end
end
