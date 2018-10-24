module Api
  module V1
    class SettingsController < ApplicationController
      before_action :set_setting, only: [:show, :update, :destroy]

      # GET /settings
      def index
        @settings = Setting.includes(:tenant).where(tenants: {isactive:true})
        render json: @settings
      end

      def setting_detail
        @setting = Setting.find_by(tenant_id: params[:tenant_id])
        render json: @setting
      end

      # GET /settings/1
      def show
        render json: @setting
      end

      # POST /settings
      def create
        
        @setting = Setting.new(setting_params)

        if @setting.save!
          render json: @setting#, status: :created, location: @setting
        else
          render json: @setting.errors#, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /settings/1
      def update
        if @setting.update(setting_params)
          render json: @setting
        else
          render json: @setting.errors, status: :unprocessable_entity
        end
      end

      # DELETE /settings/1
      def destroy
        @setting.destroy
      end



      def report_value
        tenant = params[:tenant_id]
        setting = Tenant.find(tenant).setting
        data = []
        data << {value: "Shiftwise"}
        data << {value: "Operatorwise"}
        if setting.date_wise == true
          data << {value: "Datewise Utilization"}
        end
        if setting.month_wise == true
          data << {value: "Monthwise Utilization"}
        end
        render json: {data: data}#data
      end

      def resport_split_value

        tenant = params[:tenant_id]

        if params[:report_type] == "Operatorwise" 
          setting = Tenant.find(tenant).setting
          data = []
           if setting.hour_wise == true
          data << {value: "Hourwise"}
        end
        if setting.program_wise == true
          data << {value: "ProgramNumber"}
        end
         render json: {data: data}#data
        end

        if params[:report_type] == "Shiftwise" 
          setting = Tenant.find(tenant).setting
          data = []
           if setting.hour_wise == true
          data << {value: "Hourwise"}
        end
        if setting.program_wise == true
          data << {value: "ProgramNumber"}
        end
         render json: {data: data}#data
        end


      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_setting
          @setting = Setting.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def setting_params
          params.require(:setting).permit!#(:date_wise, :month_wise, :shift_wise, :operator_wise, :shift_split, :operator_split, :sms, :notification, :tenant_id)
        end
    end
  end
end
