require 'test_helper'

class DeviceMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @device_mapping = device_mappings(:one)
  end

  test "should get index" do
    get device_mappings_url, as: :json
    assert_response :success
  end

  test "should create device_mapping" do
    assert_difference('DeviceMapping.count') do
      post device_mappings_url, params: { device_mapping: { created_by: @device_mapping.created_by, deleted_at: @device_mapping.deleted_at, device_id: @device_mapping.device_id, installing_date: @device_mapping.installing_date, is_active: @device_mapping.is_active, number_of_machine: @device_mapping.number_of_machine, reasons: @device_mapping.reasons, removing_date: @device_mapping.removing_date, tenant_id: @device_mapping.tenant_id, updated_by: @device_mapping.updated_by } }, as: :json
    end

    assert_response 201
  end

  test "should show device_mapping" do
    get device_mapping_url(@device_mapping), as: :json
    assert_response :success
  end

  test "should update device_mapping" do
    patch device_mapping_url(@device_mapping), params: { device_mapping: { created_by: @device_mapping.created_by, deleted_at: @device_mapping.deleted_at, device_id: @device_mapping.device_id, installing_date: @device_mapping.installing_date, is_active: @device_mapping.is_active, number_of_machine: @device_mapping.number_of_machine, reasons: @device_mapping.reasons, removing_date: @device_mapping.removing_date, tenant_id: @device_mapping.tenant_id, updated_by: @device_mapping.updated_by } }, as: :json
    assert_response 200
  end

  test "should destroy device_mapping" do
    assert_difference('DeviceMapping.count', -1) do
      delete device_mapping_url(@device_mapping), as: :json
    end

    assert_response 204
  end
end
