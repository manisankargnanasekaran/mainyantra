#require 'byebug'
class Machine < ApplicationRecord
acts_as_paranoid
has_many :operatorworkingdetails#,:dependent => :destroy
has_many :consummablemaintanances#,:dependent => :destroy
has_many :maintananceentries#,:dependent => :destroy
has_many :plannedmaintanances#,:dependent => :destroy
has_many :machineallocations#,:dependent => :destroy
has_many :machine_logs# ,:dependent => :destroy 
has_many :cnctools#,:dependent => :destroy
has_many :consolidate_data# ,:dependent => :destroy 
has_many :data_loss_entries# ,:dependent => :destroy 
belongs_to :tenant
validates :machine_name, presence: true
validates_format_of :device_id,presence: true, with:  /\A[A-Z]{2,5}[-]{1}[Y]{1}[0-9]{3}[-]{1}[0-9]{4}\z/,  message: "Invalid DeviceId"
enum unit: {"Unit - 1": 1, "Unit - 2": 2, "Unit - 3": 3, "Unit - 4": 4, "Unit - 5": 5}
has_many :alarms#,:dependent => :destroy
has_many :alarm_histories
has_many :machine#_daily_logs,:dependent => :destroy
has_many :machine_monthly_logs#,:dependent => :destroy
 has_many :machine_daily_logs
has_many :operator_allocations#,:dependent => :destroy
has_many :load_unloads
has_many :set_alarm_settings
has_many :reports#, :dependent => :destroy
has_many :hour_reports
has_many :program_reports

delegate :tenant_name, :to => :tenant, :prefix=> true # law of demeter in bestpractices

  def self.alert_mail # For continues data loss from Raspery Pi
    Tenant.where(isactive:true).map do |tenant|
      ProblemStatusLog.create(tenant_id:tenant.id) unless tenant.problem_status_log.present?
     
     if tenant.machines.present? && MachineLog.where(machine_id:tenant.machines.ids).count != 0
      
       time_dif = Time.now.utc - MachineLog.where(machine_id:tenant.machines.ids).order(:id).last.created_at if MachineLog.where(machine_id:tenant.machines.ids).count != 0
       time =  time_dif.nil? ? 0 : time_dif.round()/60 
        if time > 5 
          last_update = MachineLog.where(machine_id:tenant.machines.ids).order(:id).last.created_at.localtime.strftime("%d/%m/%Y ( %I:%M%p )")
          subject = "Alert Data stoppage-#{tenant.tenant_name.split(" ")[0]}(#{tenant.users[0].phone_number})"
          body = "Hi,\nI have not get any data from the below mentioned company from #{last_update}\n#{tenant.tenant_name}"
          if tenant.problem_status_log.last_mail_time.nil? || (Time.now - tenant.problem_status_log.last_mail_time)/60 > 240
           AlertMailer.send_mail(tenant.id,last_update,subject,body).deliver_now 
           tenant.problem_status_log.update(mail_status:0,last_mail_time:Time.now)
         end
        else
          if tenant.problem_status_log.mail_status == false
          subject = "Problem Rectified-#{tenant.tenant_name.split(" ")[0]}(#{tenant.users[0].phone_number})" 
          body = "Hi,\nGetting data from the below mentioned company.\n#{tenant.tenant_name}"
            last_update = MachineLog.where(machine_id:tenant.machines.ids).order(:id).last.created_at.localtime.strftime("%d/%m/%Y ( %I:%M%p )")
#.strftime("%D %I:%M %P")
            AlertMailer.send_mail(tenant.id,last_update,subject,body).deliver_now
            tenant.problem_status_log.update(mail_status:1,last_mail_time:nil)
          end
        end
     end
    end
  end

  def self.machine_job_report(params)
    tenant = Tenant.find(params[:tenant_id])
    machine_job_report = []
    if params.include?("start_date")
      total_data = MachineLog.where(:machine_id=>tenant.machines.ids)
    else
      start_time = tenant.shift.day_start_time.to_time
      end_time = tenant.shift.day_start_time.to_time + 1.day
      total_data = MachineLog.where(:machine_id=>tenant.machines.ids).where(:created_at=>start_time..end_time)
      
    end

  end

  def self.daily_maintanence(params)
#Machine.where(tenant_id:Tenant.where(isactive:true).ids).map do |machine|
# Machine.where(tenant_id:[18,121,136,187,196,199]).map do |machine|
 Machine.includes(:tenant).where(:tenants => { isactive:true } ).map do |machine| 
    data = {
     :tenant=>machine.tenant_tenant_name,# law of demeter in bestpractices
     :machine_name=>machine.machine_name,
#     :machine_status=>machine.machine_logs.last.present? ? machine.machine_logs.last.machine_status : nil,
     :last_data=>machine.machine_logs.last.present? ? machine.machine_logs.last.created_at.localtime.strftime("%d/%m/%Y ( %I:%M%p )") : nil,
     :machine_status=>machine.machine_logs.last.present? ? (Time.now - machine.machine_logs.last.created_at) > 600 ? 500 : machine.machine_logs.last.machine_status : nil
    } 
      end
end

def self.notification_mail # For continues Machine Ideal or Stop more than the time which is given by the user
#    Machine.where(tenant_id:Tenant.where(id:[18,121,136,187,199])).map do |machine|
Machine.where(tenant_id:Tenant.where(isactive:true).ids).map do |machine|
      machine_status = machine.machine_daily_logs.last.machine_status
      if machine_status != "3"
         total_time = []
         if machine_status == "100"
           machine.machine_daily_logs.order("created_at DESC").map do |log|
             break if log.machine_status != machine_status
             total_time << log.created_at
           end
         else
          machine.machine_daily_logs.order("created_at DESC").map do |log|
            break if log.machine_status == "100" || log.machine_status == "3"
            total_time << log.created_at
          end
         end
         
         time = total_time[-1].localtime.strftime("%I:%M %p")
         total_time = total_time.nil? ? 0 : total_time[0]-total_time[-1]
         if 0 < total_time
          status = machine_status == "100" ? "Stoped" : "Ideal"
          tenant = machine.tenant
            ActionMailer::Base.mail(from:"sales@yantra24x7.com",to: "manoj.rajendran@altiussolution.com,prabhu.kittusamy@altiussolution.com,saravanan.senniyappan@adcltech.com,jagadeesh@altiussolution.com",subject: "Yantra Notification-#{tenant.tenant_name.split(" ")[0]}(#{tenant.users[0].phone_number})", body: "Hi,\n
               \nYour machine id #{status} from #{time}").deliver_now
         end
      end
    end
end

def self.parts_count_calculation(machine_log)
  part_count=[]
                  part_split = machine_log.where.not(parts_count:"-1").pluck(:parts_count).split("0")
                    part_split.uniq.map do |part|
                   unless part==[]
                     if part.count!=1 # may be last shift's parts
                        if part[0].to_i > 1 # countinuation of last part
                           if part_split[0].empty?
                              part_count << part[-1].to_i
                           else 
                             part_count << part[-1].to_i - part[0].to_i
                           end
                        else
                          part_count << part[-1].to_i
                        end
                      elsif part_split.index(part) != 0 && part[0] != machine_log.first.parts_count
                          part_count << part[0].to_i
                      end
                     end
                    end
                    # parts_count = part_count.sum
                    parts_count = part_count.select(&0.method(:<)).sum
 end

          def self.calculate_total_run_time(machine_log)
                   if !machine_log.where.not(parts_count:"-1").empty?
                      total_run=[]
                      tot_run = machine_log.where.not(parts_count:"-1").pluck(:total_run_time) 
                      tot_run = tot_run.include?(0) ? tot_run.split(0).reject{|i| i.empty?} : tot_run.split(tot_run.min).reject{|i| i.empty?} 
                      tot_run.map do |run|
                          total_run << (run[-1] >= run[0] ?  run[-1] - run[0] : run[-1])
                      end
                      total_run_time = (total_run.sum)*60
                   else
                      total_run_time = 0
                   end 
          end


   def self.all_cycle_time(machine_log)
  single_part_cycle_time = []
  part_split = machine_log.where.not(parts_count:["-1","100","0"]).pluck(:parts_count).split("0")
  
  #part_split = machine_log.where(parts_count:'3').pluck(:parts_count).split('0')
  part_split.uniq.map do |parts|
    parts.uniq.map do |part| 
      program_number = machine_log.where(parts_count: part).last.programe_number
      cycle_time = machine_log.where(parts_count: part).last.run_time * 60 + machine_log.where(parts_count: part).last.run_second.to_i/1000
      #cycle_time = Time.at(machine_log.where(parts_count: part).last.run_time * 60 + machine_log.where(parts_count: part).last.run_second.to_i/1000).utc.strftime("%H:%M:%S")
      total = {program_number: program_number, cycle_time: cycle_time}
      single_part_cycle_time << total
    end
  end
  #a = single_part_cycle_time.group_by{|d| d[:program_number]}
  a = single_part_cycle_time
  return a
end
     




    def self.run_time(machine_log)
    unless machine_log.count == 0
      time = []
      final = []
      machine_log.map do |ll|
        if ll.machine_status == '3'
          final << [ll.created_at.in_time_zone("Chennai").strftime("%Y-%m-%d %I:%M:%S %P"),ll.machine_status,ll.total_run_time,ll.total_run_second]
        else
          unless final.last == "$$"
            final << "$$"
          end
        end
      end
      calculate_data = final.split("$$").reject{|i| i.empty? }
      unless calculate_data.empty?
        calculate_data.each do |data|
          if data.count == 1
            time << 5
          else
            time << data[-1][0].to_time.to_i - data[0][0].to_time.to_i
          end
        end
        return time.sum
      end
      return 0
    end
    return 0
   end  




   def self.stop_time(machine_log)
    
    unless machine_log.count == 0
      time = []
      final = []
      machine_log.map do |ll|
        if ll.machine_status == '100'
          final << [ll.created_at.in_time_zone("Chennai").strftime("%Y-%m-%d %I:%M:%S %P"),ll.machine_status,ll.total_run_time,ll.total_run_second]
        else
          unless final.last == "$$"
            final << "$$"
          end
        end
      end
      calculate_data = final.split("$$").reject{|i| i.empty? }
      unless calculate_data.empty?
        calculate_data.each do |data|
          time << data[-1][0].to_time.to_i - data[0][0].to_time.to_i
        end
        return time.sum
      end
      return 0
    end
    return 0
  end
 

  def self.ideal_time(machine_log)
    unless machine_log.count == 0
      time = []
      final = []
      machine_log.map do |ll|
        if (ll.machine_status != '3') && (ll.machine_status != '100')
          final << [ll.created_at.in_time_zone("Chennai").strftime("%Y-%m-%d %I:%M:%S %P"),ll.machine_status,ll.total_run_time,ll.total_run_second]
        else
          unless final.last == "$$"
          final << "$$"
          end
        end
      end
     
     calculate_data = final.split("$$").reject{|i| i.empty? }
     unless calculate_data.empty?
       calculate_data.each do |data|
        
        if data.count == 1
            time << 5
          else
            time << data[-1][0].to_time.to_i - data[0][0].to_time.to_i
          end
       end
      return time.sum
     end
     return 0
    end
    return 0
  end
  


     def self.new_parst_count(machine_log)
    
    total_count = []
    
    #parts = machine_log.where(machine_status: 3).where.not(parts_count: -9)#.pluck(:parts_count).uniq
    
    #part_split = machine_log.where(machine_status: 3).pluck(:parts_count).split(0)
    short_value = machine_log.where(machine_status: '3').where.not(parts_count: '-9').pluck(:programe_number, :parts_count).uniq
     if short_value.present? 
      short_value.each do |val|
        data = machine_log.find_by(parts_count: val[1], machine_status: '3', programe_number: val[0])
        if machine_log.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i == data.machine.machine_daily_logs.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i
            total_count << val[1]
          end
      end
    end
    

   return total_count.count
   end

   



    def self.cycle_time(machine_log)

    single_part_cycle_time = []
    #parts = machine_log.where(machine_status: 3).where.not(parts_count: -9)#.pluck(:parts_count).uniq
    short_value = machine_log.where(machine_status: '3').where.not(parts_count: '-9').pluck(:programe_number, :parts_count).uniq
     if short_value.present? 
      short_value.each do |val|
        data = machine_log.find_by(parts_count: val[1], machine_status: '3', programe_number: val[0])
        if machine_log.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i == data.machine.machine_daily_logs.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i
            program_number = machine_log.where(parts_count: data.parts_count, programe_number: data.programe_number).last.programe_number
            cycle_time = machine_log.where(parts_count: data.parts_count, programe_number: data.programe_number).last.run_time * 60 + machine_log.where(parts_count: data.parts_count, programe_number: data.programe_number).last.run_second.to_i/1000
            total = {program_number: program_number, cycle_time: cycle_time}
            single_part_cycle_time << total
          end
      end
    end
   return single_part_cycle_time
  end
   



    #------------------Mani-------------------------------#

   def self.run_time1(machine_log)
    unless machine_log.count == 0
      time = []
      final = []
      machine_log.map do |ll|
        if ll.machine_status == '3'
          final << [ll.created_at.in_time_zone("Chennai").strftime("%Y-%m-%d %I:%M:%S %P"),ll.machine_status,ll.total_run_time,ll.total_run_second]
        else
          unless final.last == "$$"
            final << "$$"
          end
        end
      end
      calculate_data = final.split("$$").reject{|i| i.empty? }
      unless calculate_data.empty?
        calculate_data.each do |data|
          if data.count == 1
            time << 5
          else
            time << data[-1][0].to_time.to_i - data[0][0].to_time.to_i
          end
        end
        return time.sum
      end
      return 0
    end
    return 0
  end




  def self.stop_time1(machine_log)
    
    unless machine_log.count == 0
      time = []
      final = []
      machine_log.map do |ll|
        if ll.machine_status == '100'
          final << [ll.created_at.in_time_zone("Chennai").strftime("%Y-%m-%d %I:%M:%S %P"),ll.machine_status,ll.total_run_time,ll.total_run_second]
        else
          unless final.last == "$$"
            final << "$$"
          end
        end
      end
      calculate_data = final.split("$$").reject{|i| i.empty? }
      unless calculate_data.empty?
        calculate_data.each do |data|
          time << data[-1][0].to_time.to_i - data[0][0].to_time.to_i
        end
        return time.sum
      end
      return 0
    end
    return 0
  end
 

  def self.ideal_time1(machine_log)
    unless machine_log.count == 0
      time = []
      final = []
      machine_log.map do |ll|
        if (ll.machine_status != '3') && (ll.machine_status != '100')
          final << [ll.created_at.in_time_zone("Chennai").strftime("%Y-%m-%d %I:%M:%S %P"),ll.machine_status,ll.total_run_time,ll.total_run_second]
        else
          unless final.last == "$$"
          final << "$$"
          end
        end
      end
     
     calculate_data = final.split("$$").reject{|i| i.empty? }
     unless calculate_data.empty?
       calculate_data.each do |data|
        
        if data.count == 1
            time << 5
          else
            time << data[-1][0].to_time.to_i - data[0][0].to_time.to_i
          end
       end
      return time.sum
     end
     return 0
    end
    return 0
  end

  
  def self.new_parst_count1(machine_log)
    
    total_count = []
 
    #parts = machine_log.where(machine_status: '3').where.not(parts_count: '-9')#.pluck(:parts_count).uniq
    
    #part_split = machine_log.where(machine_status: 3).pluck(:parts_count).split(0)

    short_value = machine_log.where(machine_status: '3').where.not(parts_count:'-9').pluck(:programe_number, :parts_count).uniq
     if short_value.present? 
      short_value.each do |val|

        data = machine_log.find_by(parts_count: val[1], machine_status: '3', programe_number: val[0])
        if machine_log.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i == data.machine.machine_daily_logs.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i
            total_count << val[1]
          end
      end
    end
    

   return total_count.count



   end

     

   def self.cycle_time1(machine_log)
    single_part_cycle_time = []
    #parts = machine_log.where(machine_status: 3).where.not(parts_count: -9)#.pluck(:parts_count).uniq
    short_value = machine_log.where(machine_status: '3').where.not(parts_count: -9).pluck(:programe_number, :parts_count).uniq
     
     if short_value.present? 
      short_value.each_with_index do |val,index|
        data = machine_log.find_by(parts_count: val[1], machine_status: '3', programe_number: val[0])
        if machine_log.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i == data.machine.machine_daily_logs.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i
            program_number = machine_log.where(parts_count: data.parts_count, programe_number: data.programe_number).last.programe_number
            cycle_time = machine_log.where(parts_count: data.parts_count, programe_number: data.programe_number).last.run_time * 60 + machine_log.where(parts_count: data.parts_count, programe_number: data.programe_number).last.run_second.to_i/1000
            
            total = {program_number: program_number, cycle_time: cycle_time}
            single_part_cycle_time << total
          end
      end
    end
   return single_part_cycle_time
  end

def self.start_cycle_time1(machine_log)
  cycle_start_time = []
  short_value = machine_log.where(machine_status: '3').where.not(parts_count: -9).pluck(:programe_number, :parts_count).uniq
  if short_value.present? 
      short_value.each_with_index do |val,index|
        data = machine_log.find_by(parts_count: val[1], machine_status: '3', programe_number: val[0])
        

        if machine_log.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i == data.machine.machine_daily_logs.where(parts_count: data.parts_count, machine_status: '3', programe_number: data.programe_number).last.created_at.to_i
            if short_value.count == 1
              data2 = short_value[0]
              data3 = machine_log.find_by(parts_count: data2[1], machine_status: '3', programe_number: data2[0])
              #cycle_start_time << machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).last.created_at.localtime - data.machine.machine_daily_logs.where(parts_count: data3.parts_count, programe_number: data3.programe_number).first.created_at.localtime
              cycle_start_time << machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).last.created_at.localtime - machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).first.created_at.localtime
            else
              if index == 0
                data2 = short_value[0]
                data3 = machine_log.find_by(parts_count: data2[1], machine_status: '3', programe_number: data2[0])
                #cycle_start_time << machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).first.created_at.localtime - data.machine.machine_daily_logs.where(parts_count: data.parts_count, programe_number: data.programe_number).first.created_at.localtime
                cycle_start_time << machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).last.created_at.localtime - machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).first.created_at.localtime
              elsif val == short_value[-1]
                data2 = short_value[-1]
                data3 = machine_log.find_by(parts_count: data2[1], machine_status: '3', programe_number: data2[0])
                cycle_start_time << machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).last.created_at.localtime - machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).first.created_at.localtime
              else
                data2 = short_value[index+1]
                data3 = machine_log.find_by(parts_count: data2[1], machine_status: '3', programe_number: data2[0])
                cycle_start_time << machine_log.where(parts_count: data3.parts_count, programe_number: data3.programe_number).first.created_at.localtime - machine_log.where(parts_count: val[1], machine_status: '3', programe_number: val[0]).first.created_at.localtime
                #machine_log.where(parts_count: val[1], machine_status: 3, programe_number: val[0])first.created_at.localtime - 
              end
            end
        end


      end
    end
   return cycle_start_time
end



end




