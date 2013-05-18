class Marriage
  include MongoMapper::Document
  
  key :husband_id, ObjectId
  key :wife_id,    ObjectId
  
  belongs_to :person, as: :husband
  belongs_to :person, as: :wife
end
