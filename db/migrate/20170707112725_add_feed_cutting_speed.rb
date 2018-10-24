class AddFeedCuttingSpeed < ActiveRecord::Migration[5.0]
  def change
    add_column :machine_daily_logs, :feed_rate ,:integer
   add_column :machine_daily_logs, :cutting_speed,:integer
  end
end
