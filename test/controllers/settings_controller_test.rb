require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @setting = settings(:one)
  end

  test "should get index" do
    get settings_url, as: :json
    assert_response :success
  end

  test "should create setting" do
    assert_difference('Setting.count') do
      post settings_url, params: { setting: { created_by: @setting.created_by, date_wise: @setting.date_wise, deleted_at: @setting.deleted_at, description: @setting.description, email_notification: @setting.email_notification, hour_wise: @setting.hour_wise, is_active: @setting.is_active, month_wise: @setting.month_wise, notification: @setting.notification, operator_wise: @setting.operator_wise, program_wise: @setting.program_wise, shift_wise: @setting.shift_wise, sms: @setting.sms, tenant_id: @setting.tenant_id, updated_by: @setting.updated_by } }, as: :json
    end

    assert_response 201
  end

  test "should show setting" do
    get setting_url(@setting), as: :json
    assert_response :success
  end

  test "should update setting" do
    patch setting_url(@setting), params: { setting: { created_by: @setting.created_by, date_wise: @setting.date_wise, deleted_at: @setting.deleted_at, description: @setting.description, email_notification: @setting.email_notification, hour_wise: @setting.hour_wise, is_active: @setting.is_active, month_wise: @setting.month_wise, notification: @setting.notification, operator_wise: @setting.operator_wise, program_wise: @setting.program_wise, shift_wise: @setting.shift_wise, sms: @setting.sms, tenant_id: @setting.tenant_id, updated_by: @setting.updated_by } }, as: :json
    assert_response 200
  end

  test "should destroy setting" do
    assert_difference('Setting.count', -1) do
      delete setting_url(@setting), as: :json
    end

    assert_response 204
  end
end
