class HourReport < ApplicationRecord
  belongs_to :shift
  belongs_to :operator, -> { with_deleted }, :optional=>true
  belongs_to :machine, -> { with_deleted }
  belongs_to :tenant

   def self.hour_reports(params)

  tenant=Tenant.find(params[:tenant_id])

  machines=params[:machine_id] == "undefined" ? tenant.machines.ids : Machine.where(id:params[:machine_id]).ids

  if params[:report_type] == "Shiftwise" && params[:hour_wise] == "true"

  shifts = params[:shift_id] == "undefined" ? tenant.shift.shifttransactions.pluck(:shift_no) : Shifttransaction.where(id:params[:shift_id]).pluck(:shift_no)

      return HourReport.where(:tenant_id=>tenant.id,date: params["start_date"]..params["end_date"],machine_id:machines,shift_no: shifts)

  elsif params[:report_type] == "Operatorwise" && params[:hour_wise] == "true"

      return HourReport.where(:tenant_id=>tenant.id,date: params["start_date"]..params["end_date"],machine_id:machines,:operator_id=>params[:operator_id])	

  elsif params[:report_type] == "Shiftwise" && params[:program_wise] == "true"

      shifts = params[:shift_id] == "undefined" ? tenant.shift.shifttransactions.pluck(:shift_no) : Shifttransaction.where(id:params[:shift_id]).pluck(:shift_no)

      return ProgramReport.where(:tenant_id=>tenant.id,date: params["start_date"]..params["end_date"],machine_id:machines,shift_no: shifts)

  elsif params[:report_type] == "Operatorwise" && params[:program_wise] == "true"
    
      return ProgramReport.where(:tenant_id=>tenant.id,date: params["start_date"]..params["end_date"],machine_id:machines,:operator_id=>params[:operator_id])
  else

       puts "no"
  end

 end


    
 
def self.all_cycle_time_chat(params)
  pg_num_diff = [];
  machine = Machine.where(id: params[:machine_id]).ids
  date = params[:date].to_date.strftime("%Y-%m-%d")
  shift = Shifttransaction.where(id:params[:shift_id]).pluck(:shift_no)       
  data = CncReport.where(date: date, machine_id: machine, shift_no: shift)
  if data.present?
  time = data.first.all_cycle_time#.pluck(:cycle_time)
  if time.present?
    data.first.all_cycle_time.each do |i|
    unless i[:program_number] == "" && i[:program_number] == 0 
      pg_num_diff << i
    end
  end
  start_to_start = []
  if time.present?
    data.first.cycle_start_to_start.each do |i|
    start_to_start << i
  end
end
   end
 end
 
  return pg_num_diff
end


def self.cycle_start_to_start(params)
  
  start_to_start = []
  machine = Machine.where(id: params[:machine_id]).ids
  date = params[:date].to_date.strftime("%Y-%m-%d")
  shift = Shifttransaction.where(id:params[:shift_id]).pluck(:shift_no)       
  data = CncReport.where(date: date, machine_id: machine, shift_no: shift)
  if data.present?
    time = data.first#.pluck(:cycle_time)
    if time.present?
      data.first.cycle_start_to_start.each do |i|
        start_to_start << i
      end
    end  
  end
 #end
  return start_to_start
end







def self.hour_parts_count_chart(params)
  
  machine = Machine.where(id: params[:machine_id]).ids
  date = params[:date].to_date.strftime("%Y-%m-%d")
  shift = Shifttransaction.where(id:params[:shift_id]).pluck(:shift_no)       
  data = CncHourReport.where(date: date, machine_id: machine, shift_no: shift)
  program_number = []
  data.pluck(:all_cycle_time).each do |pgnum|
    if pgnum.present?
      program_number << pgnum.pluck(:program_number)
    end
  end

  time = data.pluck(:time)
  parts = data.pluck(:parts_produced)
  parts = parts.map{|i| i.to_i}
  return {time: time, parts_count: parts, program_number: program_number}
end

def self.hour_machine_status_chart(params)

  machine = Machine.where(id: params[:machine_id]).ids
  date = params[:date].to_date.strftime("%Y-%m-%d")
  shift = Shifttransaction.where(id:params[:shift_id]).pluck(:shift_no)       
  data = CncHourReport.where(date: date, machine_id: machine, shift_no: shift)
  program_number = []
  data.pluck(:all_cycle_time).each do |pgnum|
    if pgnum.present?
      program_number << pgnum.pluck(:program_number)
    end
  end

  time = data.pluck(:time)
  actual_run = data.pluck(:run_time)
  
  actual_running = []
  actual_run.each do |time|
    t = time.to_i#Time.parse(time)
    #s1 = t.hour * 60 * 60 + t.min * 60 + t.sec
    #s2 = s1/60.to_f
    actual_running << t
  end

  load_unload = data.pluck(:stop_time)
  stop_time = []
  load_unload.each do |time|
    t = time.to_i#Time.parse(time)
    #s1 = t.hour * 60 * 60 + t.min * 60 + t.sec
    #s2 = s1/60.to_f
    stop_time << t
  end

  idle_time = data.pluck(:idle_time)
  idle = []
  idle_time.each do |time|
    t = time.to_i#Time.parse(time)
    #Time.at(t).utc.strftime("%H:%M:%S")
    #s1 = t.hour * 60 * 60 + t.min * 60 + t.sec
    #s2 = s1/60.to_f
    idle << t
  end
    totttt = []
    totttt << actual_running
    totttt << stop_time
    totttt << idle


  time_diff = data.pluck(:time_diff)
  time_diffo = []
   time_diff.each do |time|
     time_diffo << time.to_i
   end
  # @dd = []
  #time_diff.each_with_index{ |val,index| @dd << totttt.map{|a| a[index]} }
  
  # time_diff.each_with_index do |val, index|
  #   totttt.map{|i| i[index].to_i.max + time_diff[index].to_i } 
  # end       
   a = totttt.transpose
   @tot = []
  xx = []
   a.each_with_index do |tim, index|
     #tim
     time_diffo.each do |i|
      vv = tim.all? {|ti| ti == 0}
      if vv == true
        xx << tim
      else
       add_value = i[index]
       ind = tim.each_with_index.max[1]
       
       # tim.each_with_index do |v, index|
       # if index == ind
       #  xx << v + 10
       # else
       #  xx << v
       # end 
       # end
       @tot << xx
      end

     end
     
   end
    



  return {time: time, run_time: actual_running, idle_time: idle, stop_time: stop_time, program_number: program_number, no_data: time_diff}
end



def self.hour_machine_utliz_chart(params)

  machine = Machine.where(id: params[:machine_id]).ids
  date = params[:date].to_date.strftime("%Y-%m-%d")
  shift = Shifttransaction.where(id:params[:shift_id]).pluck(:shift_no)       
  data = CncHourReport.where(date: date, machine_id: machine, shift_no: shift)
  
 program_number = []
  data.pluck(:all_cycle_time).each do |pgnum|
    if pgnum.present?
      program_number << pgnum.pluck(:program_number)
    end
  end

  time = data.pluck(:time)
  actual_run = data.pluck(:run_time)
  
  actual_running = []
  actual_run.each do |time|
    s1 = time.to_i
    #t = Time.parse(time)
    #s1 = t.hour * 60 * 60 + t.min * 60 + t.sec
    s2 = s1
    actual_running << s2
  end

  load_unload = data.pluck(:stop_time)
  stop_time = []
  load_unload.each do |time|
    s1 = time.to_i
    #t = Time.parse(time)
    #s1 = t.hour * 60 * 60 + t.min * 60 + t.sec
    s2 = s1
    stop_time << s2
  end

  idle_time = data.pluck(:idle_time)
  idle = []
  idle_time.each do |time|
    s1 = time.to_i
    #t = Time.parse(time)
    #s1 = t.hour * 60 * 60 + t.min * 60 + t.sec
    s2 = s1
    idle << s2
  end
  time_diff = data.pluck(:time_diff)

  no_data = []
  time_diff.each do |time|
    s1 = time.to_i
    #t = Time.parse(time)
    #s1 = t.hour * 60 * 60 + t.min * 60 + t.sec
    s2 = s1
    no_data << s2
  end
  
  return {time: time, run_time: actual_running, idle_time: idle, stop_time: stop_time, program_number: program_number, no_data: no_data}
end


  



    def self.hourly_report
   time_now=Time.now
   date=Date.today.strftime("%Y-%m-%d")
   tenant_active=Tenant.where(id: [136])#.ids
   tenant=Tenant.find(tenant_active)
   @data = []
   machines= tenant.machines#.where(id: 21)       
   shift = Shifttransaction.current_shift(tenant.id)
   #shift = Shifttransaction.find(37)
    #if shift.shift_start_time.to_time + 1.hour  < Time.now
     if shift.shift_no == 1
       shift_no = tenant.shift.shifttransactions.last.shift_no
       date = Date.yesterday.strftime("%Y-%m-%d")
     else
       shift_no = shift.shift_no - 1
     end
       shift_id = shift.shift.id
        if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
          if Time.now.strftime("%p") == "AM"
            date = (Date.today - 1).strftime("%Y-%m-%d")
          end 
          start_time = (date+" "+shift.shift_start_time).to_time
          end_time = (date+" "+shift.shift_end_time).to_time+1.day        
        elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")
          if Time.now.strftime("%p") == "AM"
            date = (Date.today - 1).strftime("%Y-%m-%d")
          end 
          start_time = (date+" "+shift.shift_start_time).to_time+1.day
          end_time = (date+" "+shift.shift_end_time).to_time+1.day
        else
          start_time = (date+" "+shift.shift_start_time).to_time
          end_time = (date+" "+shift.shift_end_time).to_time        
        end
          
        machines.each do |mac|   
         if CncHourReport.where(date: date, shift_id: shift_id, shift_no: shift_no, tenant_id: tenant.id, machine_id: mac).present?
           cnc_h_rep = CncHourReport.where(date: date, shift_id: shift_id, shift_no: shift_no, tenant_id: tenant.id, machine_id: mac)
         end
          if cnc_h_rep.present?
             cnc_h_rep.each do |i|
               @data << i
             end
         else
          @data = []
         end
       end
         
    if @data.present?
      require 'csv'
       #path = "#{Rails.root}/public/monthly_project_cost_report_#{Date.today.strftime('%d-%m-%Y')}.csv"
       path = "#{Rails.root}/public/#{tenant.tenant_name}_#{shift_no}_#{Date.today.strftime('%d-%m-%Y')}.csv"
        CSV.open(path, "wb") do |csv|
         csv << ["Date", "Shift", "Time", "Operator Name", "Operator ID", "Machine Name", "Machine ID", "Program Number", "Job Description", "Parts Produced", "CycleTime(M:S)", "Idle Time(Hrs)", "Stop Time(Hrs)", "Actual Running(Hrs)", "Actual Working Hours", "Utilization(%.)"]
           @data.each do |detail|
            if detail.operator_id == nil
             operator_id = "Not Assigned" 
            else
              operator_id = detail.operator.operator_spec_id
            end
              if detail.operator_id == nil
               operator_name = "Not Assigned" 
              else
                operator_name = detail.operator.operator_name
              end

              if detail.all_cycle_time.present?
                cycle = detail.all_cycle_time.pluck(:cycle_time)
                avg_cycl = cycle.inject(0.0) { |sum, el| sum + el } / cycle.size
                cycle_time = Time.at(avg_cycl).utc.strftime("%H:%M:%S")
              else
                cycle_time = "00:00:00"
               end

               if detail.all_cycle_time.present?
                 pg_num = detail.all_cycle_time.pluck(:program_number).uniq.reject{|i| i == "0" || i == ""}.split(",").join(" | ")
               else
                 pg_num = "-"
               end

               if detail.idle_time.to_i >= detail.run_time.to_i && detail.idle_time.to_i >=  detail.stop_time.to_i
                idle_time = Time.at(detail.idle_time.to_i + detail.time_diff.to_i).utc.strftime("%H:%M:%S")
               else
                idle_time = Time.at(detail.idle_time.to_i).utc.strftime("%H:%M:%S")
               end

               if detail.run_time.to_i > detail.idle_time.to_i &&  detail.run_time.to_i > detail.stop_time.to_i
                 run_time = Time.at(detail.run_time.to_i + detail.time_diff.to_i).utc.strftime("%H:%M:%S")
              else
                run_time = Time.at(detail.run_time.to_i).utc.strftime("%H:%M:%S")
              end

              if detail.stop_time.to_i > detail.run_time.to_i && detail.stop_time.to_i > detail.idle_time.to_i
               stop = Time.at(detail.stop_time.to_i + detail.time_diff.to_i).utc.strftime("%H:%M:%S")
             else
               stop = Time.at(detail.stop_time.to_i).utc.strftime("%H:%M:%S")
              end
              act_work = Time.at(detail.hour.to_i).utc.strftime("%H:%M:%S")

             csv << [detail.date, detail.shift_no, detail.time, operator_name, operator_id, detail.machine.machine_name, detail.machine.machine_type, pg_num, detail.job_description, detail.parts_produced, cycle_time, idle_time, stop, run_time, act_work, detail.utilization]
           end
        end
    
        puts "ok"
        
      AlertMailer.hour_report_mail_send(path).deliver
      # @data2 = CncReport.where(date: date, shift_id: shift_id, shift_no: shift_no, tenant_id: tenant.id, machine_id: machines)
       #@data2.map{|i| i.update(is_sent: true )}
   
      File.delete(path)
    else
      puts "No Data"
      #AlertMailer.wrong_hour_report_mailer(tenant, shift, date).deliver
      #any one machine Mismatched
    end
      #@data2.update_all(is_sent: true)
    #end
  #end
end







end
