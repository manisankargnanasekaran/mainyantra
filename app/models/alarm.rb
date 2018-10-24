  require 'byebug'
  class Alarm < ApplicationRecord
    acts_as_paranoid
    belongs_to :machine

    def self.notification(params)
    	
    	machine_log = MachineLog.find(params[:machine_log_id])

    	machine_name = machine_log.machine.machine_name
      
      player_id = OneSignal.where(user_id:machine_log.machine.tenant.roles.find_by(role_name: "CEO").users.ids).pluck(:player_id).uniq

      puts player_id
    	case machine_log.machine_status
    	when "3"
    		status = "Running"
    	when "100"
    		status = "Stop"
    	else
    		status = "Idle"
    	end

      if params[:alarm_id] !=""
    		alarm_message = Alarm.find(params[:alarm_id]).alarm_message
    		message = machine_name + " : "+ alarm_message# + " and " + status
    	else
    		message = machine_name + " : " + status
    	end
      machine_id = MachineLog.find(machine_log_id).machine.id
      Notification.create(machine_log_id: machine_log.id,massage: message,machine_id:machine_id)
    	params = {"app_id" => "bec9f1f5-68b1-439a-874e-50d4df696c70", 
        "contents" => {"en" => "#{message}"},
        "include_player_ids" => player_id}
                
    	uri = URI.parse('https://onesignal.com/api/v1/notifications')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path, 'Content-Type'  => 'application/json;charset=utf-8', 'Authorization' => "Basic MzNkN2QxN2YtMjA3YS00YjJjLWIwYjEtM2Q0MmI4NTVjNzhj")
      request.body = params.as_json.to_json

      response = http.request(request)
    end
  #def self.uniq_data(params)
  #data={}
  # Alarm.limit(10).where(:machine_id=>Tenant.find(params).machines.pluck(:id)).where("DATE(created_at) = ?",Date.today).pluck(:alarm_type,:alarm_number,:alarm_message).uniq.map{|i| data={:alarm_type=>i[0],:alarm_number=>i[1],:alarm_message=>i[2]}}
  #end
  

   def self.alarm_report(params)
      date = params[:start_date]
      tenant=Tenant.find(params[:tenant_id])
      machines=params[:machine_id].present? ? Machine.where(id:params[:machine_id]) : tenant.machines 
      shiftstarttime=tenant.shift.day_start_time
      if params[:report_type] == "Shiftwise"
        (params[:start_date].to_date..params[:end_date].to_date).map(&:to_s).map do |date|
          shifts = params[:shift_id].present? ? Shifttransaction.where(id:params[:shift_id]) : tenant.shift.shifttransactions
           shifts.map do |shift|
              if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
                    start_time = (date+" "+shift.shift_start_time).to_time
                    end_time = (date+" "+shift.shift_end_time).to_time+1.day        
              elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")
                    start_time = (date+" "+shift.shift_start_time).to_time+1.day
                    end_time = (date+" "+shift.shift_end_time).to_time+1.day
              else
                    start_time = (date+" "+shift.shift_start_time).to_time
                    end_time = (date+" "+shift.shift_end_time).to_time        
              end
                end_time_for_ideal = Time.now < end_time ? Time.now : end_time
                total_shift_time_available = Time.parse(shift.actual_working_hours).seconds_since_midnight
              machines.map do | machine|
               machine.alarms.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id).map do | alarm|
                 operator_name = shift.operator_allocations.where(machine_id:machine.id).last.nil? ?  "Not Assigned" : shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.present? ? shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.operator.operator_name : "Not Assigned"
                 operator_id = shift.operator_allocations.where(machine_id:machine.id).last.nil? ?  "Not Assigned" : shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.present? ? shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.operator.operator_spec_id : "Not Assigned"
                 update=alarm.updated_at.strftime("%H:%M:%S")
                 create=alarm.created_at.strftime("%H:%M:%S")
                duration =  update.to_time - create.to_time
                  data ={
                  date:date.to_time.strftime("%d-%m-%Y"),
                  time:shift.shift_start_time+' - '+shift.shift_end_time,
                  shift_no:shift.shift_no,
                  alarm_type:alarm.present? ? alarm.alarm_type : 0,
                  alarm_number:alarm.present? ? alarm.alarm_number : 0,
                  alarm_message:alarm.present? ? alarm.alarm_message : 0,
                  #emergency:alarm.present? ? alarm.emergency : 0,
                  machine_name:alarm.present? ? alarm.machine.machine_name : 0,
                  machine_type:alarm.present? ? alarm.machine.machine_type : 0,
                  operator_name:operator_name,
                  operator_id:operator_id,
                  created_at:alarm.created_at.localtime,
                  updated_at:alarm.updated_at.localtime,
                  duration:Time.at(duration).utc.strftime("%H:%M:%S")
                  }
               end
              end
           end
        end

      elsif params[:report_type] == "Operatorwise"
          date_include_operator=OperatorMappingAllocation.where(:date=>params[:start_date].to_date..params[:end_date].to_date,:operator_id=>  params[:operator_id])  
          machines.map do | machine|
          date_include_operator.map do |operator_mapping_row| 
              shift_transaction= operator_mapping_row.operator_allocation.shifttransaction   
              machine_row = operator_mapping_row.operator_allocation.machine
                if shift_transaction.shift_start_time.include?("PM") && shift_transaction.shift_end_time.include?("AM")
                start_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_start_time).to_time
                end_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_end_time).to_time+1.day        
                elsif shift_transaction.shift_start_time.include?("AM") && shift_transaction.shift_end_time.include?("AM")
                start_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_start_time).to_time+1.day
                end_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_end_time).to_time+1.day
                else
                start_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_start_time).to_time
                end_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_end_time).to_time        
                end
                end_time_for_ideal = Time.now < end_time ? Time.now : end_time
                total_shift_time_available = Time.parse(shift_transaction.actual_working_hours).seconds_since_midnight
              
                machine.alarms.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id).map do | alarm|
                  update=alarm.updated_at.strftime("%H:%M:%S")
                 create=alarm.created_at.strftime("%H:%M:%S")
                duration =  update.to_time - create.to_time
                  data ={
                  :date=>(operator_mapping_row.date).strftime("%d-%m-%Y"),
                  :time=>shift_transaction.shift_start_time+' - '+shift_transaction.shift_end_time,
                  :shift_no =>shift_transaction.shift_no,
                  alarm_type:alarm.present? ? alarm.alarm_type : 0,
                  alarm_number:alarm.present? ? alarm.alarm_number : 0,
                  alarm_message:alarm.present? ? alarm.alarm_message : 0,
                  #emergency:alarm.present? ? alarm.emergency : 0,
                  machine_name:alarm.present? ? alarm.machine.machine_name : 0,
                  machine_type:alarm.present? ? alarm.machine.machine_type : 0,
                  operator_name:operator_mapping_row.operator.operator_name,
                  operator_id:operator_mapping_row.operator.operator_spec_id,
                  created_at:alarm.created_at.localtime,
                  updated_at:alarm.updated_at.localtime,
                  duration:Time.at(duration).utc.strftime("%H:%M:%S")
                  }
                end
              end
          end
      end
  end
   




  end
