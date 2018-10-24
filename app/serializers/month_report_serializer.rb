class MonthReportSerializer < ActiveModel::Serializer
  attributes :id, :date, :file_path
  has_one :tenant
   
def date
   object.date.strftime("%B")
end


end
