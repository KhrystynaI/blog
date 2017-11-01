# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  role                   :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime
#  updated_at             :datetime
#  address                :string
#  customer_id            :integer
#  brid                   :string
#

class User < ActiveRecord::Base
  include PublicActivity::Model

  tracked owner: ->(controller, model) { controller&.current_user },
          parameters: ->(controller, model) do
            Hash(changes: model.changes)
          end

  CUSTOM_ACTIVITIES = %i(create_snapshot load_snapshot backup restore import_orders import_files)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.policy_class
    ActiveAdmin::UserPolicy
  end

  belongs_to :customer
  has_many :document_sets, through: :subcriptions

  validates :first_name, presence: true
  validates :last_name, presence: true

  before_save :set_initial_subscriber_email

  # validates :customer_id, uniqueness: {
  #     case_sensitive: false,
  #     scope: [:first_name, :last_name],
  #     message: "Name should be unique per customer."}

  include PgSearch

  pg_search_scope :search,
                  :against => [:first_name, :last_name, :brid],
                  :using => {
                    :tsearch => {:prefix => true}
                  }

  def self.text_search(query)
    if query.present?
      search(query)
    else
      all
    end
  end

  def name
    [first_name, last_name].select(&:present?).join(' ')
  end

  alias_method :full_name, :name

  alias_method :display_name, :name
  alias_method :title, :name
  alias_method :display_title, :name

  has_many :documents, as: :assignee, foreign_key: 'assigned_to'
  has_many :document_sets, as: :assignee, foreign_key: 'assigned_to'

  belongs_to :user_role, foreign_key: 'role'

  def admin?
    role == 'admin'
  end

  def subscriber?
    role == 'subscriber'
  end

  def power_user?
    role == 'power_user'
  end

  def editor?
    role == 'editor'
  end

  scope :editors, -> do
    where(role: 'editor')
  end

  scope :employees, -> do
    where(role: ['admin', 'editor', 'power_user', '', nil])
  end

  scope :power_users, -> do
    where(role: 'power_user')
  end

  scope :subscribers, -> do
    where(role: 'subscriber')
  end

  scope :customer, ->(customer_id) do
    where(customer_id: customer_id)
  end

  def self.collection
    all.each_with_object({}) do |record, col|
      col[record.id] = record.name
    end
  end

  def self.system
    User.find_or_create_by!(email: 'system.account@contractscomplete.com') do |user|

      user.role = 'system'
      user.first_name = 'System'
      user.last_name ='Account'
      pwd = SecureRandom.hex # Account should never be used to log in.
      user.password = pwd
      user.password_confirmation = pwd
    end
  end

  def set_initial_subscriber_email
    if subscriber? && email.blank?
      self.email = "#{first_name.to_s.parameterize}.#{last_name.to_s.parameterize}@#{customer.path}-example.com"
    end
  end
end
