class JobSerializer < ActiveModel::Serializer
  attributes :id, :name, :place, :company_id, :deleted
end
