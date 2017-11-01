# == Schema Information
#
# Table name: user_roles
#
#  name        :string           primary key
#  title       :string
#  description :string
#

class UserRole < ActiveRecord::Base
  include PublicActivity::Model

  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  ROLE_NAMES = %w(admin power_user editor subscriber system)

  def display_title
    title
  end

  self.primary_key = :name

  def to_param
    name
  end

  def self.names
    ROLE_NAMES
  end

  def self.collection
    @_collection ||= all.each_with_object({}) do |record, col|
      col[record[:name]] = record[:title]
    end
  end

  def self.create_default_roles
    UserRole.find_or_create_by!(name: 'admin') do |role|
      role.title = 'Admin'
      role.description = 'Maintain Users, Customers, Vendors, Products, Standard Questions, Update Document Sets.'
    end

    UserRole.find_or_create_by!(name: 'power_user') do |role|
      role.title = 'Power User'
      role.description = 'Power Users can manage Document Sets unless restricted explicitly with a permission exception.'
    end

    UserRole.find_or_create_by!(name: 'editor') do |role|
      role.title = 'Editor'
      role.description = 'Manage permitted Documents and DocumentSets, enter Q&A.'
    end

    UserRole.find_or_create_by!(name: 'subscriber') do |role|
      role.title = 'Subscriber'
      role.description = 'Subscribers are regular CMS users who have at leas one subscription.'
    end

    UserRole.find_or_create_by!(name: 'system') do |role|
      role.title = 'System Account'
      role.description = 'System Accounts are used to run scheduled tasks without a human being logged in.'
    end
  end
end
