class CncReport < ApplicationRecord
  belongs_to :shift
  belongs_to :operator, -> { with_deleted }, :optional=>true
  belongs_to :machine, -> { with_deleted }
  belongs_to :tenant

  serialize :all_cycle_time, Array
  serialize :cycle_start_to_start, Array
  



 def self.delay_jobs
  tenants = Tenant.where(isactive: true)#isactive: true)
  tenants.each do |tenant|
       date = Date.today.strftime("%Y-%m-%d")
      shift1 = Shifttransaction.current_shift(tenant.id)
    if shift1.shift_start_time.to_time + 25.minutes > Time.now
    if shift1.shift_no == 1
	    shift = tenant.shift.shifttransactions.last
      date = Date.yesterday.strftime("%Y-%m-%d")
    else
      shift = tenant.shift.shifttransactions.where(shift_no: shift1.shift_no - 1).last
    end
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

    if shift1.shift_start_time.to_time + 25.minutes > Time.now
	    unless Delayed::Job.where(run_at: shift1.shift_start_time.to_time + 20.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_report").present?
		    CncReport.delay(run_at: shift1.shift_start_time.to_time + 20.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_report").cnc_report1(tenant.id, shift.shift_no, date)
		  end
	    unless Delayed::Job.where(run_at: shift1.shift_start_time.to_time + 15.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_hour_report").present?
	   	  CncHourReport.delay(run_at: shift1.shift_start_time.to_time + 15.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_hour_report").cnc_hour_report1(tenant.id, shift.shift_no, date)
	    end
	  end  	
    end
  end
end  
 






  
def self.delay_jobs1
  tenants = Tenant.where(isactive: true)
  tenants.each do |tenant|
   date = Date.today.strftime("%Y-%m-%d")
 # date="2018-09-16"
   tenant.shift.shifttransactions.each do |shift|
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
    
	    unless Delayed::Job.where(run_at: end_time + 20.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_report").present?
		    CncReport.delay(run_at: end_time + 20.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_report").cnc_report1(tenant.id, shift.shift_no, date)
		  end
	    unless Delayed::Job.where(run_at: end_time + 15.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_hour_report").present?
	    	if tenant.id == 136
	    		HourReport.delay(run_at: start_time + 45.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "hour_report").hourly_report
	    	end
	   	  CncHourReport.delay(run_at: end_time + 15.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_hour_report").cnc_hour_report1(tenant.id, shift.shift_no, date)
	    end
	  end
  end
end









  
    def self.cnc_report
  	#byebug
  date = Date.today.strftime("%Y-%m-%d")
  #tenants = Tenant.where(isactive: true).ids
  #date="2018-08-30"
  tenants = Tenant.where(isactive: true).ids
  @alldata = []
  tenants.each do |tenant|
	tenant = Tenant.find(tenant)
	machines = tenant.machines
	#shifts = tenant.shift.shifttransactions.ids
	#shifts.each do |shift_id|
	  #shift = Shifttransaction.find()
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
		
		  machines.order(:id).map do |mac|
			machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
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
			duration = end_time.to_i - start_time.to_i
			new_parst_count = Machine.new_parst_count1(machine_log1)
			run_time = Machine.run_time1(machine_log1)
			stop_time = Machine.stop_time1(machine_log1)
			ideal_time = Machine.ideal_time1(machine_log1)
			cycle_time = Machine.cycle_time1(machine_log1)
			start_cycle_time = Machine.start_cycle_time1(machine_log1)
			count = machine_log1.count
			time_diff = duration - (run_time+stop_time+ideal_time)

			
			utilization =(run_time*100)/duration if duration.present?

			
			@alldata << [
			  date,
			  start_time.strftime("%H:%M:%S")+' - '+end_time.strftime("%H:%M:%S"),
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
			  cycle_time,
			  start_cycle_time
			  ]
			  
		  end
		end
	 
	
  #end
  if @alldata.present?
    @alldata.each do |data|
      if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
	    CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start: data[17])
	  else
	   
        if CncReport.where(machine_id:data[6], tenant_id:data[15]).present?
		  if data[4] == 1
		    shift = Tenant.find(data[15]).shift.shifttransactions.last.shift_no
		    date = Date.yesterday.strftime("%Y-%m-%d")
		  else
		    shift = data[4] - 1
            date = data[0]
		  end
	      cnc_last_report = CncReport.last_shift_report(date, data[6], data[15], shift)
         end
        
		CncReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
	  end
    end
  end 
end




def self.last_shift_report(date, machine, tenant, shift_no)
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
         
		 machines.order(:id).map do |mac|
		  	
			machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
			
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
			duration = end_time.to_i - start_time.to_i
			new_parst_count = Machine.new_parst_count1(machine_log1)
			run_time = Machine.run_time1(machine_log1)
			stop_time = Machine.stop_time1(machine_log1)
			ideal_time = Machine.ideal_time1(machine_log1)
			cycle_time = Machine.cycle_time1(machine_log1)
			start_cycle_time = Machine.start_cycle_time1(machine_log1)
			count = machine_log1.count
			time_diff = duration - (run_time+stop_time+ideal_time)

			
			utilization =(run_time*100)/duration if duration.present?

			
			@alldata << [
			  date,
			  start_time.strftime("%H:%M:%S")+' - '+end_time.strftime("%H:%M:%S"),
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
			  cycle_time,
			  start_cycle_time
			  ]
			  
		  end
       @alldata.each do |data|
		if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
		  CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
		else
			puts "Wrong Data"
		  CncReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16])
		end
  end
end
  


   


   

def self.cnc_report1(tenant, shift_no, date)
  #date = Date.today.strftime("%Y-%m-%d")
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
  machines.order(:id).map do |mac|
		machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
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
		duration = end_time.to_i - start_time.to_i
		new_parst_count = Machine.new_parst_count1(machine_log1)
		run_time = Machine.run_time1(machine_log1)
		stop_time = Machine.stop_time1(machine_log1)
		ideal_time = Machine.ideal_time1(machine_log1)
		cycle_time = Machine.cycle_time1(machine_log1)
		start_cycle_time = Machine.start_cycle_time1(machine_log1)
		count = machine_log1.count
		time_diff = duration - (run_time+stop_time+ideal_time)
		utilization =(run_time*100)/duration if duration.present?	
		@alldata << [
		  date,
		  start_time.strftime("%H:%M:%S")+' - '+end_time.strftime("%H:%M:%S"),
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
		  cycle_time,
		  start_cycle_time
		]	  
	end
		
  
  if @alldata.present?
    @alldata.each do |data|
  
     if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
                  CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
                else
                        puts "Wrong Data"
                  CncReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
                end

     
  end
  end 
end











end
