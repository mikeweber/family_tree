class Person
  include MongoMapper::Document
  
  key :title, String
  key :first_name, String
  key :last_name, String
  key :suffix, String
  key :born_year, Integer
  key :born_month, Integer
  key :born_day, Integer
  key :died_year, Integer
  key :died_month, Integer
  key :died_day, Integer
  key :location_born, Location
  key :location_died, Location
  key :bio, String
  key :gender, String
  
  key :father_id, ObjectId
  belongs_to :father, class_name: 'Person'
  key :mother_id, ObjectId
  belongs_to :mother, class_name: 'Person'
  has_many :marriages, as: :husband
  has_many :marriages, as: :wife
  
  scope :men, where(gender: 'male').order(born_year: :desc, born_month: :desc)
  scope :women, where(gender: 'female').order(born_year: :desc, born_month: :desc)
  
  validates_presence_of :first_name, :last_name, :gender
  
  def full_name
    "#{self.title} #{self.first_name} #{self.last_name} #{self.suffix}".strip
  end
  
  def born
    [self.born_month, self.born_day, self.born_year].compact.join("/")
  end
  
  def died
    [self.died_month, self.died_day, self.died_year].compact.join("/")
  end
  
  def born_on=(date)
    self.born_year, self.born_month, self.born_day = split_date(date)
  end
  
  def born_on
    born
  end
  
  def died_on=(date)
    self.died_year, self.died_month, self.died_day = split_date(date)
  end
  
  def died_on
    died
  end
  
  def children
    Person.where("#{self.gender == 'male' ? :father : :mother}_id" => self.id)
  end
  
  def has_parent
    self.mother_id || self.father_id
  end
  
  def as_json(options = nil)
    super(methods: [:born, :died, :full_name])
  end
  
  private
  
  def split_date(date)
    parts = date.to_s.split(/[-\/]/)
    day, month, year = 1, 1, nil
    
    if parts.size == 1
      year = parts[0]
    elsif parts.size == 2
      month, year = parts
    elsif parts.size == 3
      month, day, year = parts
    end
    
    return date if year.nil?
    [year, month, day]
  end
  
  def format_date(date)
    return date unless date.is_a?(Date)
    
    date.strftime('%m/%d/%Y')
  end
end
