require 'backup/client'
class BackupService
  extend Forwardable

  def initialize
    @backup = Backup::Client.new(bucket: ENV.fetch('AWS_BACKUP_BUCKET'),
          app_path: '/var/www/contracts_complete')
  end

  def_delegators :@backup, :backup, :restore

  class << self
    def backup
      new.backup
    end

    def restore(path)
      new.restore(path)
    end
  end
end
