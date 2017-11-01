require 'backup/client'

ActiveAdmin.register_page 'Backup' do
  menu parent: 'System'

  page_action :index, method: :get do
  end

  content do
    landscapes = %w(production test)
    landscapes << ENV['LANDSCAPE'] unless landscapes.include?(ENV['LANDSCAPE'])
    landscapes.each do |landscape|
      s3 = S3::Client.new(bucket: ENV.fetch('AWS_BACKUP_BUCKET'))
      folders = s3.folders("backup/#{landscape}").sort.reverse

      h2 do
        text_node 'The list of Available backups'
      end
      h3 do
        text_node "#{landscape.capitalize} server"
      end

      table do
        thead do
          tr do
            ['Date', 'Action'].each(&method(:th))
          end
        end

        tbody do
          folders.each do |path, files|
            tr do
              td { backup_date(path) }
              td {
                link_to('Restore',
                           admin_backup_restore_path(backup_path: path), method: 'post',
                           data: { confirm: "Warning: this will replace ALL data in current #{ENV.fetch('LANDSCAPE')} environment! Restore may take several minutes. Restore now?" })
              }
            end
          end
        end
      end
    end
  end

  action_item :backup do
    link_to "Backup Now", admin_backup_perform_path, method: :post,
            data: {confirm: "Backup may take a few minutes. Run backup now?"}
  end

  page_action :perform, method: :post do
    current_user.create_activity(:backup)
    BackupService.backup

    redirect_to admin_backup_path, notice: "Backup is complete."
  end

  page_action :restore, method: :post do
    path = params[:backup_path]
    activity = current_user.create_activity(:restore_start, parameters: {restore_from: path})

    BackupService.restore(path)

    activity = current_user.create_activity(:restore, parameters: {restore_from: path})
    redirect_to admin_backup_path, notice: "Restore is complete. Data is restored from the backup'#{path}'."
  end
end
