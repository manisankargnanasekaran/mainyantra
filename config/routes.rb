Rails.application.routes.draw do
  

  resources :alarm_histories
  resources :settings
  resources :device_mappings
  resources :devices
  resources :device_types
  resources :set_alarm_settings
  resources :alarm_types
  resources :data_loss_entries
  resources :delivery_lists
  resources :job_lists
  resources :mac_id_configs
  resources :one_signals
  resources :machine_series_nos
  resources :alarm_codes
  resources :break_times
  resources :alarms
  resources :error_masters
   namespace :api, defaults: {format: 'json'} do
      namespace :v1 do
        get 'machines/api'
        get 'machines/alarm_api'
        get 'machines/consolidate_data_export'      
        get 'reports/machine_job_report'
  #----------------------------------------------#
        get 'machines/dashboard_status'
        get 'machines/machine_process'
        get 'machines/machine_counts'
        get 'machines/dashboard_live'
        get 'machines/dashboard_status_1'
 #-----------------------------------------------#
        get 'machines/client_dashboard'
        post 'tenants/tenant_user_creation'
        get 'machines/dashboard_test'
        post 'machines/dashboard_test'
        post 'shifts/shift_validation'
        post 'shifts/shift_detail'
        get 'machines/dashboard'
        post 'cncjobs/job_list'
        get 'cncjobs/all_jobs'
        get 'shifts/all_shifts'
        get 'users/pending_approvals'
        post 'machines/machinelog_entry'
        get 'machines/machine_details'
        get 'users/email_validation'
        get 'cncjobs/job_detail'
        get 'cncoperations/cncoperation_list'
        get 'machineallocations/machine_allocations_list'
        get 'users/password_recovery'
        get 'machines/machine_log_status'
        get 'machines/machine_log_status_portal'
        get 'menuconfigurations/page_detail'
        get 'notifications/insert_notification'
        get 'roles/role_detail'
        get 'cncjobs/job_page_details'
        get 'cncjobs/job_page_operation'
        get 'shifttransactions/get_all_shift'
        get 'cncjobs/job_filter'
        get 'cncjobs/opration_details'
        get 'tenants/get_all_notification'
        get 'machines/oee_calculation'
        post 'tenants/send_enquery_mail'
        get 'alarms/alarm_history'
        get 'machines/reports_page'
        get 'machines/machine_log_insert'
        get 'machines/hour_status'
        get 'alarms/alarm_dashboard'
        get 'shifttransactions/find_shift'
         #-------------------------------------#
          get 'sessions/change_pwd_web'
          get 'sessions/forgot_pwd'
         #-------------------------------------#
        get 'sessions/change_pwd'
        post 'sessions/api'
        post 'sessions/alarm'
        get 'job_lists/pending_customer_dc_list'
        get 'job_lists/job_list_detail'
        get 'machines/part_change_summery'
        get 'machines/hour_wise_detail'
        get 'machines/target_parts'
        get 'machines/status'
        put '/set_status', to: 'set_alarm_settings#set_status'
        get '/alarm_reports', to: 'alarms#report'
        post 'data_loss_entries/update_data'
        get '/alerts', to: 'notifications#alert_all'
        get '/pending_approvals', to: 'users#approval_list'
        #-------------------reports-------------#
        get '/utilization_reports',to: 'machines#date_reports'
        get '/hour_reports', to: 'machines#hour_reports'
        #------------------------------------#
        get "active_tenant" => "device_mappings#active_tenant"
        get "avialable_device" => "device_mappings#avialable_device"
        get 'active_device', to: 'device_mappings#active_device'
        get 'setting_detail' => 'settings#setting_detail'
        get 'users/admin_user'
        get 'report_value' => 'settings#report_value'
        get 'resport_split_value' => 'settings#resport_split_value'
       
        get 'all_cycle_time_chart' => 'machines#all_cycle_time_chart'
        get 'hour_parts_count_chart' => 'machines#hour_parts_count_chart'
        get 'hour_machine_status_chart' => 'machines#hour_machine_status_chart'
        get 'hour_machine_utliz_chart' => 'machines#hour_machine_utliz_chart'
        get 'cycle_start_to_start' => 'machines#cycle_start_to_start'        

        post 'alarm_last_history' => 'alarm_histories#alarm_last_history'        

        resources :alarm_histories
        resources :settings
        resources :device_mappings
        resources :devices
        resources :device_types
        resources :ethernet_logs
        resources :connection_logs
        resources :month_reports
        resources :operator_mapping_allocations
        resources :set_alarm_settings
        resources :alarm_types
        resources :data_loss_entries
        resources :delivery_lists
        resources :job_lists
        resources :operator_allocations
        resources :operators
        resources :reports
        resources :notifications
        resources :sessions
        resources :operatorproductiondetails
        resources :operatorworkingdetails
        resources :consummablemaintanances
        resources :maintananceentries
        resources :plannedmaintanances
        resources :cnctools
        resources :machineallocations
        resources :cncvendors
        resources :materials
        resources :machines
        resources :deliveries
        resources :deliverytypes
        resources :planstatuses
        resources :cncoperations
        resources :cncjobs
        resources :cncclients
        resources :menuconfigurations
        resources :pageauthorizations
        resources :pages
        resources :userslogs
        resources :roles
        resources :users
        resources :approvals
        resources :usertypes
        resources :shifttransactions
        resources :shifts
        resources :tenants
        resources :companytypes
        resources :alarms
        resources :break_times
        resources :one_signals
      end
    end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
