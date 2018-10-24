class OperatorMappingAllocationSerializer < ActiveModel::Serializer
  attributes :id,:date,:operator,:operator_allocation,:created_at
  belongs_to :operator
  belongs_to :operator_allocation
 
  def created_at
   object.created_at.localtime.strftime("%d-%m-%Y %I:%M %p")
  end
end

