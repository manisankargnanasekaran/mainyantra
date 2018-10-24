# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
  every 10.minutes do
   runner "Machine.alert_mail",:environment => :development
  end

  every 10.minutes do
   runner "Report.test_reports",:environment => :development
  end

  every 10.minutes do
  #command "/usr/bin/some_great_command"
   runner "Report.hour_report",:environment => :development
  end

  every 5.minutes do
  #command "/usr/bin/some_great_command"
   runner "Report.program_no_report",:environment => :development
  end
 
  every 1.day, at: '12:01 am' do
  # command "/usr/bin/some_great_command"
   runner "CncReport.delay_jobs1",:environment => :development
  end
 
  
 # every 60.minutes do
 #   command "/usr/bin/some_great_command"
  #  runner "CncReport.cnc_report",:environment => :development
  # end

 # every 60.minutes do
 #   command "/usr/bin/some_great_command"
  #  runner "CncHourReport.cnc_hour_report",:environment => :development
  # end



 every :sunday, at: '12pm' do
   command "/usr/bin/cmd"
  rake "log:clear"
  end

#  every 15.minute do
   #command "/usr/bin/some_great_command"
#   runner "MachineDailyLog.data_loss_entry",:environment => :development
#  end
 
 # every 15.minutes do 
  #  runner "MachineDailyLog.consolidate_data",:environment => :development
#  end 

 # every 1.day, :at => '12:30 am' do
 #   runner "MachineDailyLog.delete_data",:environment => :development
 # end


#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
