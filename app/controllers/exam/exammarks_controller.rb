class Exam::ExammarksController < ApplicationController
  filter_access_to :all #use this for new_multiple, create_multiple, edit_multiple & update_multiple to works
  #filter_resource_access
  before_action :set_exammark, only: [:show, :edit, :update, :destroy]
  before_action :set_students_exam_list, only: [:new, :create, :edit]

  # GET /exammarks
  # GET /exammarks.xml
  def index
    valid_exams = Exammark.get_valid_exams
    position_exist = @current_user.userable.positions
    if position_exist  
      lecturer_programme = @current_user.userable.positions[0].unit
      unless lecturer_programme.nil?
        programme = Programme.where('name ILIKE (?) AND ancestry_depth=?',"%#{lecturer_programme}%",0)  if !(lecturer_programme=="Pos Basik" || lecturer_programme=="Diploma Lanjutan")
      end
      unless programme.nil? || programme.count==0
        programme_id = programme.try(:first).try(:id)
        subjects_ids = Programme.where(id: programme_id).first.descendants.at_depth(2).pluck(:id)
        @exams_list = Exam.where('subject_id IN(?) and id IN(?)', subjects_ids, valid_exams).order(name: :asc, subject_id: :asc)
      else
        tasks_main = @current_user.userable.positions[0].tasks_main
        if lecturer_programme == 'Commonsubject'
          programme_id ='1'
          @exams_list = Exam.where('id IN(?)', valid_exams).order(name: :asc, subject_id: :asc)
        elsif (lecturer_programme == 'Pos Basik' || lecturer_programme == "Diploma Lanjutan") && tasks_main!=nil
          allposbasic_prog = Programme.where('course_type=? or course_type=?', "Pos Basik", "Diploma Lanjutan").pluck(:name)  #Onkologi, Perioperating, Kebidanan etc
          for basicprog in allposbasic_prog
            lecturer_basicprog_name = basicprog if tasks_main.include?(basicprog)==true
          end
          programme_id=Programme.where(name: lecturer_basicprog_name, ancestry_depth: 0).first.id
          subject_ids = Programme.where(id: programme_id).first.descendants.at_depth(2).pluck(:id)
          @exams_list = Exam.where('subject_id IN(?) and id IN(?)', subject_ids, valid_exams).order(name: :asc, subject_id: :asc)
        else
          programme_id='0'
          @exams_list = Exam.where('id IN(?)', valid_exams).order(name: :asc, subject_id: :asc)
        end
      end
      @search = Exammark.search(params[:q])
      @exammarks = @search.result.search2(programme_id)
      @exammarks = @exammarks.page(params[:page]||1)
      @exammarks_group = @exammarks.group_by{|x|x.exam_id}
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exammarks }
    end
  end

  # GET /exammarks/1
  # GET /exammarks/1.xml
  def show
    @exammark = Exammark.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exammark }
    end
  end
  
  def new
    @exammark = Exammark.new    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exammark }
    end
  end
 
  def edit
  end
  
  def create
    @exammark = Exammark.new(exammark_params)
    examid = params[:exammark][:exam_id]
    if examid!=""
      qcount = @exammark.get_questions_count(examid)
      0.upto(qcount-1) do
        @exammark.marks.build
      end
      respond_to do |format|
        if @exammark.save
          flash[:notice] = (t 'exam.exammark.title')+(t 'actions.created')
          format.html { redirect_to(edit_exam_exammark_path(@exammark), :notice =>t('exam.exammark.title')+t('actions.created')) }
          format.xml  { render :xml => @exammark }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @exammark.errors, :status => :unprocessable_entity }     
        end
      end
    else
      flash[:notice] = t 'exam.exammark.exam_compulsory'      #checking required here, as validation only done during record saving
      redirect_to new_exam_exammark_path
    end
  end
  
  # PUT /exammarks/1
  # PUT /exammarks/1.xml
  def update
    @exammark = Exammark.find(params[:id])
    @exammark.total_mcq = params[:exammark][:total_mcq] #5June2013-added refer exammark.rb(set_total_mcq) & _form.html.haml(rev 26Nov14)
    respond_to do |format|
      if @exammark.update(exammark_params)
        format.html { redirect_to(exam_exammark_path(@exammark), :notice => t('exam.exammark.title')+t('actions.updated')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exammark.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @exammark = Exammark.find(params[:id])
    @exammark.destroy
    respond_to do |format|
      format.html { redirect_to(exam_exammarks_url, :notice => t('exam.exammark.title')+t('actions.removed') ) }
      format.xml  { head :ok }
    end
  end
    
  def new_multiple
    @examid = params[:examid]
    @exammarks = Array.new(1) { Exammark.new }
    @selected_exam = Exam.find(@examid)
    @iii=Exammark.set_intake_group(@selected_exam.exam_on.year,@selected_exam.exam_on.month,@selected_exam.subject.parent.code,@current_user).to_s
    common_subject = Programme.where('course_type=?','Commonsubject').map(&:id)
    valid_exams = Exammark.get_valid_exams
    position_exist = @current_user.userable.positions
    if position_exist  
      @lecturer_programme = @current_user.userable.positions[0].unit
      unless @lecturer_programme.nil?
        programme = Programme.where('name ILIKE (?) AND ancestry_depth=?',"%#{@lecturer_programme}%",0)  if !(@lecturer_programme=="Pos Basik" || @lecturer_programme=="Diploma Lanjutan")
      end
      unless @programme.nil? || @programme.count == 0
        @programme_id = @programme.id
        @student_list = Student.where('course_id=?', @programme.id).order(name: :asc)
        @dept_unit_prog = Programme.where(id: @programme_id).first.programme_list
        @intakes_lt = @student_list.pluck(:intake).uniq
      else
        #for administrator, Posbasik, Diploma Lanjutan & Commonsubject lecturer : to assign programme, based on selected exampaper 
        if @examid
          @dept_unit = Programme.find(Exam.find(@examid).subject_id).root
          @dept_unit_prog = @dept_unit.programme_list
          @intakes_lt = Student.where('course_id=?',@dept_unit.id).pluck(:intake).uniq #must be among the programme of exampaper coz even common subject...
          @programme_id=@dept_unit.id
        end
      end
    end
  end
  
  def create_multiple
    selected_intake = params[:exammarks]["0"][:intake_id]
    @examid = params[:exammarks]["0"][:exam_id]                                                       #required if render new_multiple
    @programme_id = params[:exammarks]["0"][:programme_id]                                  #required if render new_multiple
    @selected_exam = Exam.find(@examid)                                                                   #required if render new_multiple
    @intakes_lt = Student.where('course_id=?',@programme_id).pluck(:intake).uniq    #required if render new_multiple
                                               
    @exammark = Exammark.new
    qcount = @exammark.get_questions_count(@examid)
    current_program = Programme.find(Exam.find(@examid).subject_id).root_id
    selected_student = Student.where(course_id: current_program.to_i, intake: selected_intake)
    rec_count = selected_student.count
    @exammarks = Array.new(rec_count) { Exammark.new }                      
    @exammarks.each_with_index do |exammark,ind|                                     
      exammark.student_id = selected_student[ind].id
      exammark.exam_id = @examid
      0.upto(qcount-1) do
        exammark.marks.build
      end       
    end
    if @exammarks.all?(&:valid?) 
      @exammarks.each(&:save!)
      flash[:notice] = t('exam.exammark.multiple_created')
      render :action => 'edit_multiple', :exammark_ids =>@exammarks.map(&:id)
    else                                                                      
      flash[:notice] = t('exam.exammark.marks_intakes_exist')
      render :action => 'new_multiple'
    end
  end
 
  def edit_multiple
    exammarkids = params[:exammark_ids]
    unless exammarkids.blank? 
      @exammarks = Exammark.find(exammarkids)
      student_count = @exammarks.map(&:student_id).uniq.count
      edit_type = params[:exammark_submit_button]
      if edit_type == t('edit_checked') 
        ## continue multiple edit (including subject edit here) --> refer view
      end
    else
        flash[:notice] = t 'exam.exammark.select_one'
        redirect_to exam_exammarks_path
    end
  end
  
  def update_multiple
    exammarksid = params[:exammark_ids]
    totalmcqs =params[:total_mcqs]                                          
    marks = params[:marks_attributes]
    exammarks = Exammark.find(exammarksid)	
    #below (add-in sort_by) in order to get data match accordingly to form values (sorted by student name)
    exammarks.sort_by{|x|x.studentmark.name}.each_with_index do |exammark, index| 
       exammark.total_mcq = totalmcqs[index]
       totalmarks_in_grade = 0
       exammark.marks.sort_by{|x|x.created_at}.each_with_index do |aa, cc|
         aa.student_mark = params[:marks_attributes][cc.to_s][:student_marks][index]
         totalmarks_in_grade += (params[:marks_attributes][cc.to_s][:student_marks][index]).to_f     
       end
       exammark.save 
    end
    respond_to do |format|
      format.html { redirect_to(exam_exammarks_url, :notice =>t('exam.exammark.multiple_updated')) }
      format.xml  { head :ok }
    end
  end
  
  private
    # usage - new, edit & create - @students_list & @exams_list for collection_select
    def set_students_exam_list
      valid_exams = Exammark.get_valid_exams
      position_exist = @current_user.userable.positions
      if position_exist  
        lecturer_programme = @current_user.userable.positions[0].unit
        unless lecturer_programme.nil?
          programme = Programme.where('name ILIKE (?) AND ancestry_depth=?',"%#{lecturer_programme}%",0) if !(lecturer_programme=="Pos Basik" || lecturer_programme=="Diploma Lanjutan")
        end
        unless programme.nil? || programme.count==0
          programme_id = programme.first.id
          @students_list = Student.where(course_id: programme_id).order(matrixno: :asc)
          subjects_ids = Programme.where(id: programme_id).first.descendants.at_depth(2).pluck(:id)
          @exams_list = Exam.where('subject_id IN(?) and id IN(?)', subjects_ids, valid_exams).order(name: :asc, subject_id: :asc)
        else
          tasks_main = @current_user.userable.positions[0].tasks_main
          if (lecturer_programme == 'Pos Basik' || lecturer_programme == "Diploma Lanjutan") && tasks_main!=nil
            allposbasic_prog = Programme.where('course_type=? or course_type=?', "Pos Basik", "Diploma Lanjutan").pluck(:name)  #Onkologi, Perioperating, Kebidanan etc
            for basicprog in allposbasic_prog
              lecturer_basicprog_name = basicprog if tasks_main.include?(basicprog)==true
            end
            programme_id=Programme.where(name: lecturer_basicprog_name, ancestry_depth: 0).first.id
            subject_ids = Programme.where(id: programme_id).first.descendants.at_depth(2).pluck(:id)
            @exams_list = Exam.where('subject_id IN(?) and id IN(?)', subject_ids, valid_exams).order(name: :asc, subject_id: :asc)
            @students_list = Student.where(course_id: programme_id).order(matrixno: :asc)
          end
        end
      end
    end
   # Use callbacks to share common setup or constraints between actions.
    def set_exammark
      @exammark = Exammark.find(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def exammark_params
      params.require(:exammark).permit(:student_id, :exam_id, :total_mcq, marks_attributes: [:id,:exammark_id, :student_mark])
    end
    
end
