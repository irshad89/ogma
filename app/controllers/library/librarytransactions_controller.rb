class Library::LibrarytransactionsController < ApplicationController
  
  before_action :set_librarytransaction, only: [:show, :edit, :update, :destroy]
  
  def index
    @filters = Librarytransaction::FILTERS
    if params[:show] && @filters.collect{|f| f[:scope]}.include?(params[:show])
      @librarytransactions = Librarytransaction.with_permissions_to.send(params[:show])
    else
      @librarytransactions = Librarytransaction.all
    end
    @paginated_transaction = @librarytransactions.order(checkoutdate: :desc).page(params[:page]).per(15)
    @libtran_days = @paginated_transaction.group_by {|t| t.checkoutdate}
  end
  

  # GET /librarytransactions/new
  # GET /librarytransactions/new.xml
  def new
    @librarytransaction = Librarytransaction.new
    #@librarytransaction.accession_id = 1
    #@librarytransaction.checkoutdate = Date.today()
    #@librarytransaction.returnduedate = Date.today() + 14.days
  end
  
  def show
  end
  
  def create
    #@librarytransaction = Librarytransaction.new(librarytransaction_params)

    respond_to do |format|
      if @librarytransaction.save
        format.html { redirect_to @librarytransaction, notice: 'Library was successfully created.' }
        format.json { render json: [:library, @librarytransaction], status: :created, location: [:library, @librarytransaction] }
      else
        format.html { render action: "new" }
        format.json { render json: @librarytransaction.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @librarytransaction.update(librarytransaction_params)
        format.html { redirect_to library_librarytransaction_path(@librarytransaction), notice: (t 'location.title')+(t 'actions.updated')  }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @librarytransaction.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def manager
    #set person
    @existing_library_transactions = []
    if params[:search].present? && params[:search][:staff_name].present?
      @staff_name = params[:search][:staff_name]
      @selected_staff = Staff.where("name = ?", "#{@staff_name}").first
      unless @selected_staff.nil?
        scope = Librarytransaction.where(staff: @selected_staff).where(returneddate: nil).order(returnduedate: :asc)
        @searches = scope.all
        @searches.each do |t|
          @existing_library_transactions << t
        end
      end
      @booklimit = 5
    end
    
    if params[:search].present? && params[:search][:student_icno].present?
      @student_ic = params[:search][:student_icno]
      @selected_student = Student.where("icno = ?", "#{@student_ic}").first
    end  
  end
  
  
  def check_status
    @librarytransactions = []
  
    if params[:search].present? && params[:search][:staff_name].present?
      @staff_name = params[:search][:staff_name]
      @staff_list = Staff.where("name ILIKE ?", "%#{@staff_name}%").pluck(:id)
      scope = Librarytransaction.where("staff_id IN (?) AND returneddate IS ?", @staff_list, nil)
      @searches = scope.all
      @searches.each do |t|
        @librarytransactions << t
      end
    end
    
    if params[:search].present? && params[:search][:student_icno].present?
      @student_ic = params[:search][:student_icno]
      @student_list = Student.where("icno LIKE ?", "#{@student_ic}%").pluck(:id)
      scope = Librarytransaction.where("student_id IN (?) AND returneddate IS ?", @student_list, nil)
      @searches = scope.all
      @searches.each do |t|
        @librarytransactions << t
      end
    end  
  end
  
  def late_books
    @staff_late_books = Librarytransaction.find_by_sql("
      SELECT s.name as name, s.coemail, b.title
      FROM librarytransactions lt
      LEFT JOIN staffs s on s.id=lt.staff_id
      LEFT JOIN accessions a on a.id=lt.accession_id
      LEFT OUTER JOIN books b on b.id=a.book_id
      WHERE lt.returned IS NULL
      AND s.coemail IS NOT NULL
      AND lt.returnduedate < current_date
      GROUP BY name, s.coemail, b.title;")
      
    @student_late_books = Librarytransaction.find_by_sql("
      SELECT s.name as name, s.coemail, b.title, 
      FROM librarytransactions lt
      LEFT JOIN student s on s.id=lt.student_id
      LEFT JOIN accessions a on a.id=lt.accession_id
      LEFT OUTER JOIN books b on b.id=a.book_id
      WHERE lt.returned IS NULL
      AND s.coemail IS NOT NULL
      AND lt.returnduedate < current_date
      GROUP BY name, s.coemail, b.title;")
    
  end
  
  
  
  def extend
    @librarytransaction = Librarytransaction.find(params[:id])
  end
  
  def extend2
    @librarytransaction = Librarytransaction.find(params[:id])
    render :layout => false
  end
  
  def return
    @librarytransaction = Librarytransaction.find(params[:id])
  end
  
  def return2
    @librarytransaction = Librarytransaction.find(params[:id])
    render :layout => false
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_librarytransaction
      @librarytransaction = Librarytransaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def librarytransaction_params
      params.require(:librarytransaction).permit(:accession_id, :staff_id, :student_id, :checkoutdate, :returnduedate, :accession_no, :accession_acc_book)
      # <-- insert editable fields here inside here e.g (:date, :name)
    end
  
end
  