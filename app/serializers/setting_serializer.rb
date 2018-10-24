class SettingSerializer < ActiveModel::Serializer
  attributes :id, :date_wise, :month_wise, :shift_wise, :operator_wise, :email_notification, :hour_wise, :program_wise, :sms, :notification, :description, :created_by, :updated_by, :is_active, :deleted_at
  has_one :tenant
end
