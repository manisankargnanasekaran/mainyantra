class Device < ApplicationRecord
   acts_as_paranoid
  has_many :device_mappings
  belongs_to :device_type,:optional=>true
end
