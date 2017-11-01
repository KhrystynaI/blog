# == Schema Information
#
# Table name: fields
#
#  id           :integer          not null, primary key
#  subject_id   :integer
#  subject_type :string
#  title        :string
#  value        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Field < ActiveRecord::Base
end
