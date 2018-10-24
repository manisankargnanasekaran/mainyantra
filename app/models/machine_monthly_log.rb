class MachineMonthlyLog < ApplicationRecord
  belongs_to :machine, -> { with_deleted }


def self.month_details
    
   # tenant=Tenant.where(isactive: true).ids
#    start_date= Date.today.beginning_of_month - 7.month
 #   end_date= Date.today.end_of_month - 7.month
start_date="2017-08-01"
end_date="2017-08-31"
        
           @data=[]
        #date = params[:start_date]
        tenant=Tenant.find(18)
        #tenant=Tenant.where(isactive: true)
        machines= tenant.machines 
        shiftstarttime=tenant.shift.day_start_time
        #if params[:report_type] == "Shiftwise"

        (start_date..end_date).map do |date|
        shifts = tenant.shift.shifttransactions
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
        machines.order(:id).map do |mac|
        machine_log = mac.machine_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
        #machine_log = mac.machine_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
        total_shift_time_available_for_downtime =  Time.now - start_time

        unless machine_log.present?
        downtime = 0
        else
        time_difference = (machine_log.first.created_at.to_time.seconds_since_midnight - shift.shift_start_time.to_time.utc.seconds_since_midnight)/60

        if time_difference >= 10 
        total_run_time = machine_log.last.total_run_time.nil? ? 0 : machine_log.last.total_run_time*60
        else
        total_run_time = (machine_log.last.total_run_time.to_i - machine_log.first.total_run_time.to_i)*60

        end 

        parts_count = Machine.parts_count_calculation(machine_log)#
        total_shift_time_available_for_downtime = total_shift_time_available_for_downtime < 0 ? total_shift_time_available_for_downtime*-1 : total_shift_time_available_for_downtime

        total_run_time = Machine.calculate_total_run_time(machine_log)#Reffer Machine model                    

        parts_count_splitup=[]
        machine_log.pluck(:programe_number).uniq.reject{|i| i == "" || i.nil?}.map do |j_name| 
        job_name = "O"+j_name
        if machine_log.where.not(parts_count:"-1").where(programe_number:j_name).count != 0 
        part_count = machine_log.where.not(parts_count:"-1").where(:programe_number=>j_name).pluck(:parts_count).uniq.reject{|i| i == "0"}.count - 1 
        else
        part_count = 0
        end
        parts_count_splitup << {:job_name=>job_name,:part_count=>part_count}
        end
        all_jobs = machine_log.where.not(parts_count:"-1").pluck(:programe_number).uniq.reject{|i| i == ""}
        total_load_unload_time=[]
        targeted_parts=[]

        all_jobs.map do |job|
        job_wise_cycle_time = []
        job_wise_load_unload = []
        job_part = machine_log.where.not(parts_count:"-1").where(programe_number:job).pluck(:parts_count).uniq.reject{|part| part == "0"}
        job_part.shift
        job_part.pop if job_part.count > 1
        job_part_load_unload = machine_log.where.not(parts_count:"-1").where(programe_number:job).pluck(:parts_count).uniq
        if job_part_load_unload[0] == "0" || job_part_load_unload[0] == machine_log.first.parts_count
        job_part_load_unload.shift if job_part_load_unload[0].to_i > 1
        end

        job_part_load_unload = job_part_load_unload.reject{|i| i=="0"}
        job_wise_cycle_time = machine_log.where(programe_number:job).where(parts_count:job_part).group_by(&:parts_count).map{|pp,qq| (qq.last.created_at - qq.first.created_at)}
        job_wise_cycle_time = job_wise_cycle_time.reject{|i| i <= 0}
        targeted_parts << (machine_log.where(programe_number:job).where(parts_count:job_part[-1]).order(:id).last.created_at - machine_log.where(programe_number:job).where(parts_count:job_part[0]).order(:id).first.created_at) / job_wise_cycle_time.min if machine_log.where(programe_number:job).where(parts_count:job_part[0]).order(:id).last.present? && !job_wise_cycle_time.min.nil?

        job_wise_load_unload = machine_log.where(programe_number:job).where(parts_count:job_part).group_by(&:parts_count).map{|pp,qq| (qq.last.created_at - qq.first.created_at) - (qq.last.run_time*60 + qq.last.run_second.to_i/1000)}
        job_wise_load_unload = job_wise_load_unload.reject{|i| i <= 0 }
        unless job_wise_load_unload.min.nil?
        total_load_unload_time << job_wise_load_unload.min*job_part_load_unload.count
        end

        end

        total_load_unload_time = total_load_unload_time.sum
        targeted_parts = targeted_parts[0].to_s=="Infinity" ? 0 : targeted_parts.sum

        cutting_time = (machine_log.last.total_cutting_time.to_i - machine_log.first.total_cutting_time.to_i)*60
        total_shift_time_available = ((total_shift_time_available/60).round())*60
        # downtime = (total_shift_time_available - total_run_time).round()
        #downtime = (total_shift_time_available_for_downtime - total_run_time).round()
           downtime =  ((end_time_for_ideal-start_time)-total_run_time).round()
        job_description = machine_log.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
        end

        total_shift_time_available = total_shift_time_available #- break_minute if machine_log.where.not(parts_count:"-1").count != 0
        utilization =(total_run_time*100)/total_shift_time_available if machine_log.where.not(:parts_count=>"-1").count != 0# && machine_log.where.not(:machine_status=>"0").count != 0
      #  total_shift_time_available = total_shift_time_available + break_minute if downtime < 0
        utilization = utilization.nil? ? 0 : utilization
        #operator_name = shift.operator_allocations.where(machine_id:mac.id).where("created_at >=? AND created_at <=?",date.to_date,date.to_date + 1.day).last.present? ? shift.operator_allocations.where(machine_id:mac.id).where("created_at >=? AND created_at <=?",date.to_date,date.to_date + 1.day).last.operator.operator_name+"-"+shift.operator_allocations.where(machine_id:mac.id).where("created_at >=? AND created_at <=?",date.to_date,date.to_date + 1.day).last.created_at.strftime("%D %I:%M %p") : "Not Assigned"
        #operator_id = shift.operator_allocations.where(machine_id:mac.id).where("created_at >=? AND created_at <=?",date.to_date,date.to_date + 1.day).last.present? ? shift.operator_allocations.where(machine_id:mac.id).where("created_at >=? AND created_at <=?",date.to_date,date.to_date + 1.day).last.operator.operator_spec_id : "Not Assigned"
        operator_name = shift.operator_allocations.where(machine_id:mac.id).last.nil? ?  "Not Assigned" : shift.operator_allocations.where(machine_id:mac.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.present? ? shift.operator_allocations.where(machine_id:mac.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.operator.operator_name : "Not Assigned"
                  operator_id = shift.operator_allocations.where(machine_id:mac.id).last.nil? ?  "Not Assigned" : shift.operator_allocations.where(machine_id:mac.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.present? ? shift.operator_allocations.where(machine_id:mac.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.operator.operator_spec_id : "Not Assigned"
        total_load_unload_time = total_load_unload_time.nil? ? 0 : total_load_unload_time

        #idle_time = downtime - total_load_unload_time
        idle_time = downtime - total_load_unload_time < 0 ? 0 : downtime - total_load_unload_time
        total_run_time = total_run_time.nil? ? 0 : total_run_time
        targeted_parts = targeted_parts.nil? ? 0 : targeted_parts.round()
        controller_part = machine_log.where.not(parts_count:"-1").last.present? ? machine_log.where.not(parts_count:"-1").last.parts_count : 0
        parts_count = parts_count.to_i < 0 ? controller_part : parts_count
        #parts_count = parts_count.to_i.nil? ? 0 : parts_count
        parts_last = (controller_part.to_i)
        operator_efficiency = (parts_count*100/targeted_parts).round() unless targeted_parts == 0

          @data << [date,
                    shift.shift_no,
                    shift.shift_start_time+' - '+shift.shift_end_time,
                    operator_name,
                    operator_id,
                    mac.machine_name,
                    mac.machine_type,
                    machine_log.pluck(:programe_number).uniq.reject{|i| i == "0" || i == ""}.split(",").join(" | "),
                    job_description.nil? ? "-" : job_description.split(',').join(" & "),
                    parts_count,
                    #parts_count.to_i > 0  ? machine_log.where(:parts_count=>machine_log.last.parts_count.to_i - 1).present? ? Time.at(machine_log.where(:parts_count=>machine_log.last.parts_count.to_i - 1).last.run_time*60 + machine_log.where(:parts_count=>machine_log.last.parts_count.to_i - 1).last.run_second.to_i/1000).utc.strftime("%H:%M:%S") : 0 : 0,
                    parts_count.to_i > 0  ? machine_log.where(:parts_count=>parts_last).present? ? Time.at(machine_log.where(:parts_count=>parts_last).first.run_time*60 + machine_log.where(:parts_count=>parts_last).first.run_second.to_i/1000).utc.strftime("%H:%M:%S") : 0 : 0,
                    Time.at(total_load_unload_time).utc.strftime("%H:%M:%S"),
                    Time.at(idle_time).utc.strftime("%H:%M:%S"),
                    Time.at(downtime).utc.strftime("%H:%M:%S"),
                    Time.at(total_run_time).utc.strftime("%H:%M:%S"),
                    shift.actual_working_hours,
                    #targeted_parts,
                    #operator_efficiency,
                    utilization.nil? || utilization < 0 ? 0 : utilization.round()
          ]
          
        end
        end
end
        
     path="#{Rails.root}/public/test/#{tenant.tenant_name+"-"+start_date.strftime("%B")}.csv"
      CSV.open(path,"wb") do |csv|
        # csv << ["date","time","shift_no","machine_name","machine_type","idle_time","downtime","total_load_unload_time","parts_count","utilization","operator_name","operator_id","programe_number","job_description","targeted_parts","total_run_time","operator_efficiency"]
        csv << ["Date","Shift","Time","Operator MFR","Operator ID","Machine Name" ,"Machine ID","Program Number","Job Description","Parts Produced(No's)","Cycle Time(M:S)","Loading and Unloading Time(Hrs)","Idle Time (Hrs)","Total Downtime(Hrs)","Actual Running(Hrs)","Actual Working Hours" ,"Utilization"]
         @data.map {|i| csv << i} 
      end 
         #MonthReport.create(:date=>start_date,:tenant_id=>tenant.id,:file_path=>File.open(path, "rb"))
#         FileUtils.rm(path)     
  end

end
