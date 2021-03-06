class StaffAppraisal < ActiveRecord::Base
  
   before_validation :set_year_to_start
   before_save :set_to_nil_where_false, :set_number_of_questions, :when_ppp_is_ppk
 
   belongs_to :appraised,      :class_name => 'Staff', :foreign_key => 'staff_id'
   belongs_to :eval1_officer,  :class_name => 'Staff', :foreign_key => 'eval1_by'
   belongs_to :eval2_officer,  :class_name => 'Staff', :foreign_key => 'eval2_by'
  
   has_many :staff_appraisal_skts, :dependent => :destroy
   accepts_nested_attributes_for :staff_appraisal_skts, :allow_destroy => true, :reject_if => lambda { |a| a[:description].blank? }
  
   has_many :evactivities, :foreign_key => 'appraisal_id', :dependent => :destroy
   accepts_nested_attributes_for :evactivities, :allow_destroy => true, :reject_if => lambda { |a| a[:evactivity].blank? }
  
   has_many :trainneeds, :foreign_key => 'evaluation_id', :dependent => :destroy
   accepts_nested_attributes_for :trainneeds, :allow_destroy => true, :reject_if => lambda { |a| a[:name].blank? }
  
   validates_presence_of :evaluation_year
   validates_uniqueness_of :evaluation_year, :scope => :staff_id, :message => "Your evaluation for this year already exists"

   # define scope
   def self.status_search(query) 
     if query == '1'
       evalstatus = where('is_skt_submit !=?', true)
     elsif query == '2'
       evalstatus = where('is_complete=?', true) 
     elsif query == '3'
       evalstatus = where('is_skt_submit =? AND is_skt_endorsed is null', true) 
     elsif query == '4'
       evalstatus = where('is_skt_submit =? AND is_skt_endorsed =? AND is_skt_pyd_report_done is null',  true,  true) 
     elsif query == '5'
       evalstatus = where('is_skt_pyd_report_done =? AND is_skt_ppp_report_done is null', true) 
     elsif query == '6'
       evalstatus = where('is_skt_pyd_report_done =? AND is_skt_ppp_report_done =? AND is_submit_for_evaluation is null', true, true)
     elsif query == '7'
       evalstatus = where('is_skt_ppp_report_done =? AND is_submit_for_evaluation =? AND is_submit_e2 is null',  true, true) 
     elsif query == '8'
       evalstatus = where('is_submit_for_evaluation =? AND is_submit_e2 =? AND is_complete is null', true, true) 
     else
       evalstatus = StaffAppraisal.all
     end 
     evalstatus
   end

   # whitelist the scope
   def self.ransackable_scopes(auth_object = nil)
     [:status_search]
   end 
      
   def evaluation_status
     if is_skt_submit != true
       I18n.t('staff.staff_appraisal.skt_being_formulated')
     elsif is_complete == true
       I18n.t('staff.staff_appraisal.staff_appraisal_complete')
     elsif is_skt_submit == true && is_skt_endorsed != true
       I18n.t('staff.staff_appraisal.skt_awaiting_ppp_endorsement')
     elsif is_skt_submit == true && is_skt_endorsed == true && is_skt_pyd_report_done != true
       I18n.t('staff.staff_appraisal.skt_review')
     elsif is_skt_pyd_report_done == true && is_skt_ppp_report_done != true
       I18n.t('staff.staff_appraisal.ready_for_ppp_skt_report')
     elsif is_skt_pyd_report_done == true && is_skt_ppp_report_done == true && is_submit_for_evaluation != true
       I18n.t('staff.staff_appraisal.ppp_report_complete')
     elsif is_skt_ppp_report_done == true && is_submit_for_evaluation == true && is_submit_e2 != true
       I18n.t('staff.staff_appraisal.submitted_for_evaluation_by_ppp')
    elsif is_submit_for_evaluation == true && is_submit_e2 == true
       I18n.t('staff.staff_appraisal.submitted_by_ppp_for_evaluation_to_PPK')
     end
   end   
 
   def set_year_to_start
     self.evaluation_year = evaluation_year.to_date.at_beginning_of_year  if evaluation_year
   end
 
   #def evaluation_status
     #if is_skt_submit != true
    #   "SKT being formulated"
     #elsif is_complete == true
      # "Staff Appraisal complete"
     #elsif is_skt_submit == true && is_skt_endorsed != true
      # "SKT awaiting PPP endorsement"
     #elsif is_skt_submit == true && is_skt_endorsed == true && is_skt_pyd_report_done != true
      # "SKT Review"
     #elsif is_skt_pyd_report_done == true && is_skt_ppp_report_done != true
      # "Ready for PPP SKT Report"
     #elsif is_skt_pyd_report_done == true && is_skt_ppp_report_done == true && is_submit_for_evaluation != true
      # "PPP Report complete"
    # elsif is_skt_ppp_report_done == true && is_submit_for_evaluation == true && is_submit_e2 != true
     #  "Submitted for Evaluation by PPP"
     #elsif is_submit_for_evaluation == true && is_submit_e2 == true
      # "Submitted by PPP for Evaluation  to PPK"
     #end
  # end
 
   #before logic
  def set_to_nil_where_false
    if is_skt_submit != true
      self.skt_submit_on= nil
    end 
    if is_skt_endorsed != true
      self.skt_endorsed_on= nil
    end
    if is_skt_pyd_report_done != true
      self.skt_pyd_report_on= nil
    end
    if is_skt_ppp_report_done != true
      self.skt_ppp_report_on= nil
    end
    if is_submit_for_evaluation == false
      self.submit_for_evaluation_on= nil
    end
    if is_submit_e2 == false
      self.submit_e2_on= nil
    end
    if is_complete == false
      self.is_completed_on= nil
    end
  end
  
  #logic to set editable
  def edit_icon
    if evaluation_status == "SKT awaiting PPP endorsement" #&& staff_id == Login.current_login.staff_id
      "noedit"
    elsif evaluation_status == "SKT awaiting PPP endorsement" #&& eval1_by == Login.current_login.staff_id
      "approval.png"
    elsif evaluation_status == "SKT Review" #&& eval1_by == Login.current_login.staff_id
      "noedit"
    elsif evaluation_status == "Ready for PPP SKT Report" #&& staff_id == Login.current_login.staff_id
      "noedit"
    elsif evaluation_status == "PPP Report complete" #&& eval1_by == Login.current_login.staff_id
      "noedit"
    elsif evaluation_status == "Submitted for Evaluation by PPP" #&& staff_id == Login.current_login.staff_id
      "noedit"
    elsif evaluation_status == "Submitted for Evaluation by PPP to PPK" #&& staff_id == Login.current_login.staff_id
      "noedit"
    elsif evaluation_status == "Submitted by PPP for Evaluation  to PPK" #&& eval1_by == Login.current_login.staff_id
      "noedit"
    elsif is_complete == true
      "noedit"
    else
      "edit.png"
    end
  end
  
  def set_number_of_questions
    self.g1_questions = 5
    if appraised.staffgrade.name.last(2).to_i <= 16
      self.g2_questions = 4
      self.g3_questions = 3
    elsif appraised.staffgrade.name.last(2).to_i >= 41
      self.g2_questions = 3
      self.g3_questions = 5
    else
      self.g2_questions = 3
      self.g3_questions = 4
    end
  end

  def when_ppp_is_ppk
    if eval1_by == eval2_by && e1_total != nil #> 1
      self.e2g1q1        =  e1g1q1
      self.e2g1q2        =  e1g1q2
      self.e2g1q3        =  e1g1q3
      self.e2g1q4        =  e1g1q4
      self.e2g1q5        =  e1g1q5
      self.e2g1_total    =  e1g1_total
      self.e2g1_percent  =  e1g1_percent
      #self.g2_questions  =  g3_questions
      self.e2g2q1        =  e1g2q1
      self.e2g2q2        =  e1g2q2
      self.e2g2q3        =  e1g2q3
      self.e2g2q4        =  e1g2q4
      self.e2g2_total    =  e1g2_total
      self.e2g2_percent  =  e1g2_percent
      self.e2g3q1        =  e1g3q1
      self.e2g3q2        =  e1g3q2
      self.e2g3q3        =  e1g3q3
      self.e2g3q4        =  e1g3q4
      self.e2g3q5        =  e1g3q5
      self.e2g3_total    =  e1g3_total
      self.e2g3_percent  =  e1g3_percent
      self.e2g4          =  e1g4
      self.e2g4_percent  =  e1g4_percent
      self.e2_total      =  e1_total
      self.e2_years      =  e1_years
      self.e2_months     =  e1_months
      self.is_submit_e2  =  false
      self.submit_e2_on  =  Date.today
    end 
  end
  
  def person_type
    if appraised.staffgrade.name.last(2).to_i <= 16
      5
    elsif appraised.staffgrade.name.last(2).to_i >= 41
      3
    else
      4
    end
  end
 
end