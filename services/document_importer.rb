require_relative 'backup_service'
require_relative 's3_sync'
require 'data_import/documents/importer'
require 'google_drive/syncer'

class DocumentImporter
  def perform(user:, need_backup:)
    if need_backup
      user.create_activity(:backup)
      BackupService.backup
    end

    if need_sync_files
      sync = GoogleDrive::Syncer.new(remote_folder_id: Setting.google_drive_folder_id, local_path: local_path)
      sync.call
    end

    importer = DataImport::Documents::Importer.new(
      import_path: local_path)
    importer.perform

    activity = user.create_activity(:import_documents,
                                    parameters: {results: importer.logs},
                                    owner: user)
  end

  private

  def local_path
    File.join(Rails.root, 'file_import')
  end

  def need_sync_files
    true
  end
end
