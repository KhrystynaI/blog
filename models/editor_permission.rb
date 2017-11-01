# == Schema Information
#
# Table name: editor_permissions
#
#  id      :integer          not null, primary key
#  doc_id  :string
#  user_id :integer
#

class EditorPermission < ActiveRecord::Base
  belongs_to :user
end
