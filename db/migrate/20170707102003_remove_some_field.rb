class RemoveSomeField < ActiveRecord::Migration[5.0]
  def change
   remove_column :machine_logs, :cutting_time
   remove_column :machine_logs, :cycle_time
  end
end
