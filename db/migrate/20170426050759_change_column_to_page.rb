class ChangeColumnToPage < ActiveRecord::Migration[5.0]
  def change
      remove_column :pages, :usertype_id
      add_reference :pages, :companytype, foreign_key: true
  end
end
