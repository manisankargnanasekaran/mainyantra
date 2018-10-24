class AddProgrameNumber < ActiveRecord::Migration[5.0]
  def change
  	 add_column :machine_logs, :programe_number,:string
  	 add_column :machine_logs, :programe_description,:string
     add_column :machine_daily_logs, :programe_number,:string
  	 add_column :machine_daily_logs, :programe_description,:string
  end
end
