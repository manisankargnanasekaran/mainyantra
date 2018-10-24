class Planstatus < ApplicationRecord
has_many :cncoperations,:dependent => :destroy
end
