class AddCncjobIdToMachineLog < ActiveRecord::Migration[5.0]
  def change
    add_reference :machine_logs, :cncjob, foreign_key: true, :null => true
  end
end
