class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.string :device_name
      t.references :device_type, foreign_key: true
      t.text :description
      t.date :purchase_date
      t.string :created_by
      t.string :updated_by
      t.boolean :is_active, default:true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :devices, :device_name, unique: true
  end
end
