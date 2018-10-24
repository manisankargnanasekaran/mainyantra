class AddDeletedAtToOperatorworkingdetails < ActiveRecord::Migration[5.0]
  def change
    add_column :operatorworkingdetails, :deleted_at, :datetime
    add_index :operatorworkingdetails, :deleted_at
  end
end
