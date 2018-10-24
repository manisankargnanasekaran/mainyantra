class CreateDeviceMappings < ActiveRecord::Migration[5.0]
  def change
    create_table :device_mappings do |t|
      t.date :installing_date
      t.date :removing_date
      t.integer :number_of_machine
      t.text :description 
      t.text :reasons
      t.references :tenant, foreign_key: true
      t.references :device, foreign_key: true
      t.string :created_by
      t.string :updated_by
      t.boolean :is_active, default:true
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
