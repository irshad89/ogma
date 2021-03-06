class Kin < ActiveRecord::Base
  belongs_to :staff
  belongs_to :student
end

# == Schema Information
#
# Table name: kins
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  kinaddr    :string(255)
#  kinbirthdt :date
#  kintype_id :integer
#  mykadno    :string(255)
#  name       :string(255)
#  phone      :string(255)
#  profession :string(255)
#  staff_id   :integer
#  student_id :integer
#  updated_at :datetime
#
