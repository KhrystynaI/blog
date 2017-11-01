require 'system/utils'

class S3Sync
  extend System::Utils

  def self.load_files(bucket:, remote_folder:, local_folder:)
    s3_path = File.join(bucket, remote_folder)
    delete_empty_folders(local_folder)
    run "aws s3 sync --debug --delete s3://#{s3_path} #{local_folder}"
  rescue => error
    Rails.logger.warn("Error synching files: #{error.message}")
  end
end
