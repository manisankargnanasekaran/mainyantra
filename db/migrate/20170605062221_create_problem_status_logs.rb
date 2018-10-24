class CreateProblemStatusLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :problem_status_logs do |t|
      t.boolean :mail_status
      t.datetime :last_mail_time
      t.belongs_to :tenant, foreign_key: true

      t.timestamps
    end
  end
end
