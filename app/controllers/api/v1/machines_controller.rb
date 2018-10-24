module Api
  module V1
class MachinesController < ApplicationController
  before_action :set_machine, only: [:show, :update, :destroy]

  # GET /machines
  def index

#    @machines = Tenant.find(params[:tenant_id]).machines
    @machines = Machine.where(tenant_id: params[:tenant_id])

    render json: @machines
  end
 
  # GET /machines/1
  def show
    render json: @machine
  end

  # POST /machines
  def create
    @machine = Machine.new(machine_params)
    if @machine.save
       @set_alarm_setting = SetAlarmSetting.create!([{:alarm_for=>"idle", :machine_id=>@machine.id},{:alarm_for=>"stop", :machine_id=>@machine.id}])
      render json: @machine, status: :created#, location: @machine
    else
      render json: @machine.errors, status: :unprocessable_entity
    end
  end

  def all_jobs
    jobs = Cncjob.job_list_process(params)
    render json: jobs
  end
 
  def dashboard_test
    data=MachineDailyLog.dashboard_process(params)
    render json: data
  end

 def dashboard_live
    data=MachineDailyLog.dashboard_process(params)
   if data != nil
     running_count1 = []
  df= {}
  data.group_by{|d| d[:unit]}.map do |key2,value2|
     value={}
     value2.group_by{|i| i[:machine_status]}.map do |k,v|
      k = "waste"  if k == nil
      k = "stop"  if k == "100"
      k = "running"  if k == "3"
      k = "idle"  if k == "0" 
      k = "idle1" if k == "1"
      value[k] = v.count
     end
     df[key2] = value
   end
    render json: {"data" => data.group_by{|d| d[:unit]}, count: df}
  end
end

def dashboard_status_1

  data1=MachineDailyLog.dashboard_status(params)
  running_count = []
  ff = {}
  data1.group_by{|d| d[:unit]}.map do |key1,value1|
     value={}
     value1.group_by{|i| i[:machine_status]}.map do |k,v|
      k = "waste"  if k == nil
      k = "stop"  if k == "100"
      k = "running"  if k == "3"
      k = "idle"  if k == "0" 
      k = "idle1" if k == "1"
      value[k] = v.count
     end
     ff[key1] = value
  end
render json: {"data" => data1.group_by{|d| d[:unit]}, count: ff}
end

  def dashboard_status
   data1=MachineDailyLog.dashboard_status(params)
   render json: data1
  end


  def machine_process
   machine=MachineDailyLog.machine_process(params)
   render json: machine
  end


  def machine_counts
   machine_data = Machine.where(:tenant_id=>params[:tenant_id]).count
   render json: {"machine_count": machine_data}
  end

   def machine_details
    data = MachineLog.machine_process(params)
    render json: data
  end

  def hour_reports
   data =HourReport.hour_reports(params)  
   render json: data
   end

  def date_reports
   date_report = Report.date_reports(params).flatten
   render json: date_report
   end


  # PATCH/PUT /machines/1
  def update
    if @machine.update(machine_params)
#      @set_alarm_setting = SetAlarmSetting.create!([{:alarm_for=>"idle", :machine_id=>@machine.id},{:alarm_for=>"stop", :machine_id=>@machine.id}])
      render json: @machine
    else
      render json: @machine.errors, status: :unprocessable_entity
    end
  end

  # DELETE /machines/1
  def destroy
    if @machine.destroy
      render json: true
    else
      render json: false
    end
    # @machine.update(isactive:0)
  end

  def machine_log_status
    final_data = MachineLog.stopage_time_details(params)
    render json: final_data
  end

  def machine_log_status_portal 
    final_data = MachineLog.stopage_time_details_portal(params)
    render json: final_data
  end

  def oee_calculation
    oee_final = MachineLog.oee_calculation(params)
    render json: oee_final
  end

  def reports_page
   # @report=MachineLog.reports(params).flatten
    @report=Report.reports(params).order(:date,:shift_no)
    render json: @report#.flatten
  end 
  

  def hour_status
    data = MachineLog.hour_detail(params)
    render json: data
  end 
  
  def status
     daily_status =Machine.daily_maintanence(params)
     render json: daily_status
  end

  def machine_log_insert
  end

  def part_change_summery
    data = MachineLog.part_summery(params)
    render json: data
  end

  def hour_wise_detail
    data = MachineLog.hour_wise_status(params)
    render json: data
  end

  def consolidate_data_export
    data = ConsolidateDatum.export_data(params)
    render json: data
  end
  
  def target_parts
    data = MachineDailyLog.target_parts(params)
    render json: data
  end  
  #####################33
# data insert API
   def api
        mac_id = Machine.find_by_machine_ip(params[:machine_id])
        MachineLog.create(machine_status: params[:machine_status],parts_count: params[:parts_count],machine_id: mac_id.id,
                job_id: params[:job_id],total_run_time: params[:total_run_time],total_cutting_time: params[:total_cutting_time],
                run_time: params[:run_time],feed_rate: params[:feed_rate],cutting_speed: params[:cutting_speed],
                total_run_second:params[:total_cutting_time_second],run_second: params[:run_time_seconds],programe_number: params[:programe_number])
        MachineDailyLog.create(machine_status: params[:machine_status],parts_count: params[:parts_count],machine_id: mac_id.id,
                job_id: params[:job_id],total_run_time: params[:total_run_time],total_cutting_time: params[:total_cutting_time],
                run_time: params[:run_time],feed_rate: params[:feed_rate],cutting_speed: params[:cutting_speed],
                total_run_second:params[:total_cutting_time_second],run_second: params[:run_time_seconds],programe_number: params[:programe_number])
  end

    def all_cycle_time_chart #chat1
    all_cycle_time_chat = HourReport.all_cycle_time_chat(params)
    render json: all_cycle_time_chat
  end

  def hour_parts_count_chart #chat2
    hour_parts_count_chart = HourReport.hour_parts_count_chart(params)
    render json: hour_parts_count_chart 
  end

  def hour_machine_status_chart #chat3
    hour_machine_status_chart = HourReport.hour_machine_status_chart(params)
    render json: hour_machine_status_chart
  end

  def hour_machine_utliz_chart #chat4
    hour_machine_utliz_chart = HourReport.hour_machine_utliz_chart(params)
    render json: hour_machine_utliz_chart
  end

  def cycle_start_to_start
    data = HourReport.cycle_start_to_start(params)
    render json: data
  end


  def alarm_api
    mac=Machine.find_by_machine_ip(params[:machine_id])
      iid = mac.nil? ? 0 : mac.id
       unless (mac.alarm.last.alarm_type == params[:alarm_type]) && ((Time.now - mac.alarm.last.updated_at) >= 120)
         Alarm.create(alarm_type: params[:alarm_type],alarm_number:params[:alarm_number],alarm_message: params[:alarm_message],emergency: params[:emergency],machine_id: iid)
       else
        mac.alarm.last.update(updated_at:Time.now)
       end
  end

#########################

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_machine
      @machine = Machine.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def machine_params
      params.require(:machine).permit(:machine_name, :machine_model, :machine_serial_no, :machine_type,:machine_ip, :tenant_id,:unit,:device_id)
    end
end
end
end
