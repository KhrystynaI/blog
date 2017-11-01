# == Schema Information
#
# Table name: permission_exceptions
#
#  id      :integer          not null, primary key
#  doc_id  :string
#  user_id :integer
#

class PermissionException < ActiveRecord::Base
  belongs_to :user

end
