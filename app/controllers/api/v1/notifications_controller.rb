require 'net/http'
require 'uri'
module Api
  module V1
    class NotificationsController < ApplicationController


  # GET /notifications
  def insert_notification
 	#byebug
  	Alarm.notification(params)
    #render json: {"machine_log_id": params[:machine_log_id], "machine_log_status": params[:machine_log_status]}
    
  end
    def alert_all
     notification=Notification.where(machine_id:Tenant.find(params[:tenant_id]).machines.ids).order("id").last(20)
     render json: notification
    end

  end
  end
end
