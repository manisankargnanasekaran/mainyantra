class UserSerializer < ActiveModel::Serializer
  attributes :id ,:first_name,:last_name,:email_id,:phone_number,:remarks,:usertype_id,:approval_id,:tenant,:role_id,:isactive
  belongs_to :tenant
end

