class CncHourReport < ApplicationRecord
  belongs_to :shift
  belongs_to :operator, -> { with_deleted }, :optional=>true
  belongs_to :machine, -> { with_deleted }
  belongs_to :tenant

  serialize :all_cycle_time, Array
  serialize :cycle_start_to_start, Array
   

   
  def self.cnc_hour_report
  date = Date.today.strftime("%Y-%m-%d")
  #date="2018-08-30"
  tenants = Tenant.where(isactive: true).ids
  #tenants = Tenant.where(isactive: true).ids
  @alldata = []
  tenants.each do |tenant|
	tenant = Tenant.find(tenant)
	machines = tenant.machines
	#shifts = tenant.shift.shifttransactions.ids
	#shifts.each do |shift_id|
	 #shift = Shifttransaction.find(12)
	  shift = Shifttransaction.current_shift(tenant.id)
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
		
	  #if start_time < Time.now && end_time > Time.now
		
		#loop_count = 1
		(start_time.to_i..end_time.to_i).step(3600) do |hour|
		  (hour.to_i+3600 <= end_time.to_i) ? (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(hour.to_i+3600).strftime("%Y-%m-%d %H:%M")) : (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(end_time).strftime("%Y-%m-%d %H:%M"))
		  unless hour_start_time[0].to_time == hour_end_time.to_time
		  machines.order(:id).map do |mac|
			machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",hour_start_time[0].to_time,hour_end_time.to_time).order(:id)
			if shift.operator_allocations.where(machine_id:mac.id).last.nil?
			  operator_id = nil
			else
			  if shift.operator_allocations.where(machine_id:mac.id).present?
				shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
				  aa = ro.from_date
				  bb = ro.to_date
				  cc = date
				  if cc.to_date.between?(aa.to_date,bb.to_date)  
					dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
					if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
					  operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id 
					else
					  operator_id = nil
					end              
				  end
				end
			  else
				operator_id = nil
			  end
			end
			job_description = machine_log1.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
			duration = hour_end_time.to_time.to_i - hour_start_time[0].to_time.to_i
			new_parst_count = Machine.new_parst_count1(machine_log1)
			run_time = Machine.run_time1(machine_log1)
			stop_time = Machine.stop_time1(machine_log1)
			ideal_time = Machine.ideal_time1(machine_log1)
			cycle_time = Machine.cycle_time1(machine_log1)
			count = machine_log1.count
			time_diff = duration - (run_time+stop_time+ideal_time)
			utilization =(run_time*100)/duration if duration.present?
				
			@alldata << [
			  date,
			  hour_start_time[0].split(" ")[1]+' - '+hour_end_time.split(" ")[1],
			  duration,
			  shift.shift.id,
			  shift.shift_no,
			  operator_id,
			  mac.id,
			  job_description.nil? ? "-" : job_description.split(',').join(" & "),
			  new_parst_count,
			  run_time,
			  ideal_time,
			  stop_time,
			  time_diff,
			  count,
			  utilization,
			  tenant.id,
			  cycle_time
			  ]  
		  end
		#end
	 end    
	end
  end
  @alldata.each do |data|
		if CncHourReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
		  CncHourReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16])
		else
		    if CncHourReport.where(machine_id:data[6], tenant_id:data[15]).present?
			  if data[4] == 1
			    shift = Tenant.find(data[15]).shift.shifttransactions.last.shift_no
			    date = Date.yesterday.strftime("%Y-%m-%d")
			  else
			    shift = data[4] - 1
			    date = data[0]
			  end
			  cnc_last_report = CncHourReport.last_hour_report(date, data[6], data[15], shift)
		    end
		  CncHourReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16])
		end
  end 
end


def self.last_hour_report(date, machine, tenant, shift_no)
	@alldata = []
  date = date
  tenant = Tenant.find(tenant)
  machines = Machine.where(id: machine)
  shift = tenant.shift.shifttransactions.find_by(shift_no: shift_no)
 
	  #shift = Shifttransaction.current_shift(tenant.id)
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
        
		(start_time.to_i..end_time.to_i).step(3600) do |hour|
			
		  (hour.to_i+3600 <= end_time.to_i) ? (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(hour.to_i+3600).strftime("%Y-%m-%d %H:%M")) : (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(end_time).strftime("%Y-%m-%d %H:%M"))
		  unless hour_start_time[0].to_time == hour_end_time.to_time
		    machines.order(:id).map do |mac|
			    machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",hour_start_time[0].to_time,hour_end_time.to_time).order(:id)
					if shift.operator_allocations.where(machine_id:mac.id).last.nil?
					  operator_id = nil
					else
					  if shift.operator_allocations.where(machine_id:mac.id).present?
						shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
						  aa = ro.from_date
						  bb = ro.to_date
						  cc = date
						  if cc.to_date.between?(aa.to_date,bb.to_date)  
							dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
							if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
							  operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id 
							else
							  operator_id = nil
							end              
						  end
						end
					  else
						operator_id = nil
					  end
					end
			job_description = machine_log1.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
			duration = hour_end_time.to_time.to_i - hour_start_time[0].to_time.to_i
			new_parst_count = Machine.new_parst_count1(machine_log1)
			run_time = Machine.run_time1(machine_log1)
			stop_time = Machine.stop_time1(machine_log1)
			ideal_time = Machine.ideal_time1(machine_log1)
			cycle_time = Machine.cycle_time1(machine_log1)
			count = machine_log1.count
			time_diff = duration - (run_time+stop_time+ideal_time)
			
			utilization =(run_time*100)/duration if duration.present?
				
			@alldata << [
			  date,
			  hour_start_time[0].split(" ")[1]+' - '+hour_end_time.split(" ")[1],
			  duration,
			  shift.shift.id,
			  shift.shift_no,
			  operator_id,
			  mac.id,
			  job_description.nil? ? "-" : job_description.split(',').join(" & "),
			  new_parst_count,
			  run_time,
			  ideal_time,
			  stop_time,
			  time_diff,
			  count,
			  utilization,
			  tenant.id,
			  cycle_time
			  ]  
		  end
		#end
	 end 
  end
  @alldata.each do |data|
		if CncHourReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
		  CncHourReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16])
		else
			puts "Wrong Data"
      #		  CncHourReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16])
		end
  end


end


   def self.cnc_hour_report1(tenant, shift_no, date)
   date = date
   @alldata = []
   tenant = Tenant.find(tenant)
   machines = tenant.machines
   shift = tenant.shift.shifttransactions.where(shift_no: shift_no).last
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
	  # if shift.day == 1
   #     start_time = (date+" "+shift.shift_start_time).to_time
   #     end_time = (date+" "+shift.shift_end_time).to_time
   #   else
   #     start_time = (date+" "+shift.shift_start_time).to_time+1.day
   #     end_time = (date+" "+shift.shift_end_time).to_time+1.day
   #   end
	 start_time = (date+" "+shift.shift_start_time).to_time+1.day
	 end_time = (date+" "+shift.shift_end_time).to_time+1.day
	else              
	  start_time = (date+" "+shift.shift_start_time).to_time
	  end_time = (date+" "+shift.shift_end_time).to_time        
	end
	(start_time.to_i..end_time.to_i).step(3600) do |hour|
	  (hour.to_i+3600 <= end_time.to_i) ? (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(hour.to_i+3600).strftime("%Y-%m-%d %H:%M")) : (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(end_time).strftime("%Y-%m-%d %H:%M"))
	  unless hour_start_time[0].to_time == hour_end_time.to_time
	    machines.order(:id).map do |mac|
		    machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",hour_start_time[0].to_time,hour_end_time.to_time).order(:id)
			  if shift.operator_allocations.where(machine_id:mac.id).last.nil?
			    operator_id = nil
			  else
				  if shift.operator_allocations.where(machine_id:mac.id).present?
					  shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
						  aa = ro.from_date
						  bb = ro.to_date
						  cc = date
					    if cc.to_date.between?(aa.to_date,bb.to_date)  
						    dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
						    if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
						      operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id 
						    else
						      operator_id = nil
						    end              
					    end
					  end
				  else
					  operator_id = nil
				  end
			  end
				job_description = machine_log1.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
				duration = hour_end_time.to_time.to_i - hour_start_time[0].to_time.to_i
				new_parst_count = Machine.new_parst_count1(machine_log1)
				run_time = Machine.run_time1(machine_log1)
				stop_time = Machine.stop_time1(machine_log1)
				ideal_time = Machine.ideal_time1(machine_log1)
				cycle_time = Machine.cycle_time1(machine_log1)
				count = machine_log1.count
				time_diff = duration - (run_time+stop_time+ideal_time)
				utilization =(run_time*100)/duration if duration.present?
			
				@alldata << [
				  date,
				  hour_start_time[0].split(" ")[1]+' - '+hour_end_time.split(" ")[1],
				  duration,
				  shift.shift.id,
				  shift.shift_no,
				  operator_id,
				  mac.id,
				  job_description.nil? ? "-" : job_description.split(',').join(" & "),
				  new_parst_count,
				  run_time,
				  ideal_time,
				  stop_time,
				  time_diff,
				  count,
				  utilization,
				  tenant.id,
				  cycle_time
				  ]  
	    end
    end    
  end
  if @alldata.present?
	  @alldata.each do |data|
                  if CncHourReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?	  
                  CncHourReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16])
                else
                  CncHourReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16])
                end

           end 
	 end
end















end
