class CreateMachineLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :machine_logs do |t|
      t.string :last_reset_time
      t.string :parts_count
      t.string :machine_status
      t.string :last_machine_on
      t.string :last_machine_off
      t.belongs_to :machine, foreign_key: true

      t.timestamps
    end
  end
end
