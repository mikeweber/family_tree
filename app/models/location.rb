class Location
  include MongoMapper::Document
  
  key :name, String
  key :latitude, Float
  key :longitude, Float
  
  has_many :people, as: :births
  has_many :people, as: :deaths
  
end
