class ChangeStringToText < ActiveRecord::Migration[5.0]
  def change
     change_column :reports, :program_number, :text
     change_column :reports, :job_description, :text
     change_column :hour_reports, :program_number, :text
     change_column :hour_reports, :job_description, :text
     change_column :program_reports, :program_number, :text
     change_column :program_reports, :job_description, :text
  end
end
