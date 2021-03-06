class Tenant < ActiveRecord::Base
  before_save :save_my_vars
  belongs_to :location, touch: true
  belongs_to :staff
  belongs_to :student
  has_many  :damages, :class_name => 'LocationDamage', :foreign_key => 'user_id', :dependent => :destroy
  accepts_nested_attributes_for :damages, :allow_destroy => true, reject_if: proc { |damages| damages[:description].blank?}
  
  
  #student autocomplete
  def student_icno
    student.try(:student_list)
  end

  def student_icno=(icno)
    icno2 = icno.split(" ")[0]
    #self.student = Student.find_or_create_by_icno(icno2) if icno2.present?
    self.student = Student.find_or_create_by(icno: icno2) if icno2.present?
  end
  
  def save_my_vars
    if id.nil? || id.blank?
      self.force_vacate = 0
    end
  end
  
end

# == Schema Information
#
# Table name: tenants
#
#  created_at        :datetime
#  force_vacate      :boolean
#  id                :integer          not null, primary key
#  keyaccept         :date
#  keyexpectedreturn :date
#  keyreturned       :date
#  location_id       :integer
#  staff_id          :integer
#  student_id        :integer
#  updated_at        :datetime
#
