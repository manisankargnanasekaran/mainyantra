class SetAlarmSetting < ApplicationRecord
  belongs_to :machine, -> { with_deleted }
end
