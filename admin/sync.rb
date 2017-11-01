ActiveAdmin.register_page 'Sync' do
  menu parent: 'System', label: 'Copy production data'

  page_action :index, method: :get do
    @syncer = Snapshot.new(bucket: ENV.fetch('AWS_APP_BUCKET'))
  end

  content do
    render partial: 'index'
  end

  page_action :create_snapshot, method: :post do
    syncer = Snapshot.new(bucket: ENV.fetch('AWS_APP_BUCKET'))
    syncer.create_snapshot
    current_user.create_activity(:create_snapshot)
    redirect_to admin_sync_path, notice: "Creation a snapshot is complete."
  end

  page_action :load_snapshot, method: :post do
    syncer = Snapshot.new(bucket: ENV.fetch('AWS_APP_BUCKET'))
    syncer.load_snapshot
    current_user.create_activity(:load_snapshot)
    redirect_to admin_sync_path, notice: 'Loading a snapshot is complete.'
  end
end
