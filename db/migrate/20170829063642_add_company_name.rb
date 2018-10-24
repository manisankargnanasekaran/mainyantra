class AddCompanyName < ActiveRecord::Migration[5.0]
  def change
    add_column :cncclients, :company_name, :string
    add_column :cncclients, :address, :string
    add_column :job_lists, :completed_status, :boolean
    add_reference :delivery_lists, :cncclient, index: true
  end
end
