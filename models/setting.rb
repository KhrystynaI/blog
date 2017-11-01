# == Schema Information
#
# Table name: settings
#
#  section     :string
#  name        :string           primary key
#  description :text
#  value       :text
#

class Setting < ActiveRecord::Base

  include Auditable

  self.primary_key = :name

  def self.sections
    Setting.uniq.pluck('section')
  end

  def self.[](name)
    Setting.find_by(name: name)&.value
  end

  def self.set!(name, value)
    Setting.find_by(name: name).update!(:value, value)
  end

  def self.google_drive_folder_url
    Setting['google_drive_folder_url']
  end

  def self.google_drive_folder_id
    Setting['google_drive_folder_url'].split('/').last
  end

  def self.create_default_settings
    Setting.find_or_create_by(name: 'google_drive_folder_url') do |setting|
      setting.section = 'File Import'
      setting.description = "The URL of the Google Drive folder containing files for import. \n"\
          "This folder should be shared with the CMS service account file-import@contractscomplete.iam.gserviceaccount.com. \n"\
          "If you navigate the url and have access permissions, you should see the list of subfolders named after the Customers."

      setting.value = 'https://drive.google.com/drive/folders/0B4Xw73hG_zb7VWhNNGppTmxwS00'
    end
  end
end
