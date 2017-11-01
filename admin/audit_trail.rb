ActiveAdmin.register Activity, as: 'Audit Trail' do
  menu parent: 'System', :label => 'Audit Trail'

  actions :all, except: [:destroy, :edit, :new]

  index do
    column 'Date' do |activity|
      activity.created_at.strftime('%F %R')
    end
    column 'User' do |activity|
      activity.owner&.name
    end
    column 'Action' do |activity|
      title = "#{activity.key.split('.').last.to_s.humanize} "
      title += "#{activity.trackable.class.name}: #{activity.trackable.display_title }" if activity.trackable
      title
    end
    column 'Changes' do |activity|
      visible_changes activity
    end
  end

  filter :created_at, label: 'Date'
  filter :doc_id, label: 'Doc Set ID', filters: [:equals, :contains]
  filter :parameters, label: 'Updated Value', filters: [:contains]
  filter :owner, as: :select, collection: -> { User.employees.all }
end
