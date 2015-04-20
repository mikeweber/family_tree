module ApplicationHelper
  def lifespan(born, died)
    [born, died].reject { |d| d.blank? }.compact.join(' - ')
  end

  def top_offset(born_year)
    Person.where(:born_year.lte => born_year, :$or => [{ :died_year.gte => born_year }, { :$ne => '' }]).count
  end
end
