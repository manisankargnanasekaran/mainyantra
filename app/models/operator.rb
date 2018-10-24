class Operator < ApplicationRecord
 acts_as_paranoid
has_many :operator_allocations# ,:dependent => :destroy
belongs_to :tenant
has_many :operator_mapping_allocations# ,:dependent => :destroy
has_many :reports#, :dependent => :destroy
has_many :hour_reports
has_many :program_reports
end
