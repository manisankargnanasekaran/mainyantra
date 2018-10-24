 module Api
  module V1 

class AlarmHistoriesController < ApplicationController
  before_action :set_alarm_history, only: [:show, :update, :destroy]

  # GET /alarm_histories
  def index
   # @alarm_histories = AlarmHistory.all
    @alarm_histories = AlarmHistory.includes(:machine).where(machines: {tenant_id:params[:tenant_id]})#.order(:time)
    render json: @alarm_histories
   # render json: @alarm_histories
  end

  # GET /alarm_histories/1
  def show
    render json: @alarm_history
  end

  # POST /alarm_histories
  def create
    @alarm_history = AlarmHistory.new(alarm_history_params)

    if @alarm_history.save
      render json: @alarm_history, status: :created, location: @alarm_history
    else
      render json: @alarm_history.errors, status: :unprocessable_entity
    end
  end
  

  def alarm_last_history # Last 50
  
    mac = Machine.find_by_machine_ip(params[:machine_id])
   
    if mac.alarm_histories.where(alarm_type: params[:alarm_type], alarm_no: params[:alarm_no], axis_no: params[:axis_no], time: params[:time], message:params[:message]).last.present?
    puts "Old Alarms"
    else
    AlarmHistory.create(alarm_type: params[:alarm_type], alarm_no: params[:alarm_no], axis_no: params[:axis_no], time: params[:time], message:params[:message], alarm_status:params[:alarm_status], machine_id:mac.id)
    end


   
end








  # PATCH/PUT /alarm_histories/1
  def update
    if @alarm_history.update(alarm_history_params)
      render json: @alarm_history
    else
      render json: @alarm_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /alarm_histories/1
  def destroy
    @alarm_history.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alarm_history
      @alarm_history = AlarmHistory.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def alarm_history_params
      params.require(:alarm_history).permit(:alarm_type, :alarm_no, :axis_no, :time, :message, :alarm_status, :machine_id)
    end
end
end
end
