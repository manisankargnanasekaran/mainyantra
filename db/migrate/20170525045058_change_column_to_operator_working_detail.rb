class ChangeColumnToOperatorWorkingDetail < ActiveRecord::Migration[5.0]
  def change
     change_table :operatorworkingdetails do |t|
      t.change :from_time,:string
      t.change :to_time,:string
#      t.change :actual_working_hours,:string
    end
  end
end
