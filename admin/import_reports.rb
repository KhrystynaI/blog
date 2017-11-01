ActiveAdmin.register ActivityReport, as: 'Import Reports' do
  menu parent: 'System', :label => 'Import Reports'

  scope 'Subscriptions', :imports_subscriptions, default: true
  scope 'Files', :imports_documents

  actions :all, except: [:destroy, :edit, :new]

  index do
    column 'Date' do |activity|
      activity.created_at.strftime('%F %R')
    end
    column 'User' do |activity|
      activity.owner&.name
    end
    column 'Results' do |activity|
      link_to('View', admin_import_report_path(activity.id))
    end
  end

  show title: 'Import report' do |activity|
    if activity.key == 'user.import_subscriptions'
      render 'show_import_subscriptions',
             results: activity.results,
             user: activity.owner,
             import_date: activity.created_at,
             duration: activity.duration
    elsif activity.key == 'user.import_documents'
      render 'show_import_documents',
             results: activity.results,
             user: activity.owner,
             import_date: activity.created_at,
             duration: activity.duration
    end
  end

  def apply_filter(array)
    array
  end

  member_action :json do
    render json: resource.results
  end

  filter :created_at, label: 'Date'
  filter :owner, label: 'User', collection: User.employees
end
