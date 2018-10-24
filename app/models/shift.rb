class Shift < ApplicationRecord
	acts_as_paranoid
  has_many :shifttransactions,:dependent => :destroy
  belongs_to :tenant
has_many :reports#, :dependent => :destroy
has_many :hour_reports
has_many :program_reports

  def self.get_all_shift(params)
  	shifts=Tenant.find(params[:tenant_id]).shift.shifttransactions
  	return shifts
  end
end
