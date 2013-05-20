class PeopleController < ApplicationController
  before_filter :find
  
  def index
    @people = Person.order(born_year: :desc, born_month: :desc)
  end
  
  def timeline
    @people = Person.order(born_year: :desc, born_month: :desc).all
    render layout: 'timeline'
  end
  
  def family_tree
    mother = @person.mother
    father = @person.father
    respond_to do |format|
      format.html do
        @people = [@person, mother, father].compact
        render action: 'timeline', layout: 'timeline'
      end
      format.json { render json: { person: @person, mother: mother, father: father } }
    end
  end
  
  def show
    @children = @person.children
  end
  
  def new
    @person = Person.new(params[:person])
    @person.last_name = @person.father.last_name if @person.father
    @men = Person.men
    @women = Person.women
  end
  
  def create
    @person = Person.new(params[:person])
    
    if @person.save
      respond_to do |format|
        format.html { redirect_to person_path(@person) }
        format.json { head :created }
      end
    else
      respond_to do |format|
        format.html do
          @men = Person.men
          @women = Person.women
          render action: 'new'
        end
        format.json { render status: :bad_request, person: @person }
      end
    end
  end
  
  def edit
    @men = Person.men
    @women = Person.women
  end
  
  def update
    @person.attributes = params[:person]
    if @person.save
      respond_to do |format|
        format.html { redirect_to person_path(@person) }
        format.json { head :updated }
      end
    else
      respond_to do |format|
        format.html do
          @men = Person.men
          @women = Person.women
          render action: 'edit'
        end
        format.json { render status: :bad_request, person: @person }
      end
    end
  end
  
  def destroy
    @person.destroy
    
    respond_to do |format|
      format.html do
        flash[:notice] = "#{@person.full_name} removed"
        redirect_to people_path
      end
      format.json { head :ok }
    end
  end
  
  private
  
  def find
    return true if params[:id].blank?
    
    unless @person = Person.find(params[:id])
      respond_to do |format|
        format.html do
          flash[:notice] = "Could not find person with id '#{params[:id]}'"
          redirect_to people_path
        end
        format.json { render status: :not_found }
      end
      return false
    end
  end
end
