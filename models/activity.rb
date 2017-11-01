# == Schema Information
#
# Table name: activities
#
#  id              :integer          not null, primary key
#  trackable_id    :integer
#  trackable_type  :string
#  owner_id        :integer
#  owner_type      :string
#  key             :string
#  parameters      :text
#  recipient_id    :integer
#  recipient_type  :string
#  created_at      :datetime
#  updated_at      :datetime
#  doc_id          :string
#  document_set_id :integer
#
require 'public_activity/testing'
class Activity < PublicActivity::Activity
  IMPORT_SUBSCRIPTIONS = :import_subscriptions

  def self.policy_class
    ActiveAdmin::ActivityPolicy
  end

  scope :imports, -> {
    where(key: ['user.import_subscriptions', 'user.import_documents'])
  }

  scope :imports_subscriptions, -> {
    where(key: :'user.import_subscriptions')
  }

  scope :imports_documents, -> {
    where(key: :'user.import_documents')
  }

  def activity_type
    key.split('.').last.to_sym
  end

  def data_changes
    return nil if parameters[:changes].nil?

    return Hash[parameters[:attributes].map do |key, value|
      [key, [value, nil]]
    end] if activity_type == :destroy && parameters[:attributes]

    parameters[:changes].delete_if do |key, _|
      %w(created_at updated_at).include? key
    end
  end

  def results
    parameters[:results]
  end

  def duration
    parameters[:duration]
  end

end
