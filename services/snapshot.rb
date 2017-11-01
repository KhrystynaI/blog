require 'system/utils'
require 's3/client'
# Helps copy production data to test server.
class Snapshot
  include System::Utils

  attr_reader :bucket, :storage, :env

  def initialize(bucket:)
    @env = Rails.env rescue 'test'
    @storage = S3::Client.new(bucket: bucket)
    @bucket = bucket
  end

  def deploy_path
    '/var/www/contracts_complete'
  end

  def upload_path
    "#{deploy_path}/shared/upload"
  end

  def current_path
    "#{deploy_path}/current"
  end

  def create_snapshot
    run ". #{current_path}/.env && PGPASSWORD=$CMS_DB_PWD pg_dump -U cms -h localhost --clean cms > #{upload_path}/cms.sql"
    # 'aws s3 sync --debug --delete /var/www/contracts_complete/shared/upload s3://cms-contractscomplete/upload/production'
    delete_empty_folders(upload_path)
    run "aws s3 sync --debug --delete #{upload_path} s3://#{bucket}/upload/production"
  end

  def load_snapshot
    delete_empty_folders(upload_path)
    # 'aws s3 sync s3://cms-contractscomplete/upload/production /var/www/contracts_complete/shared/upload'
    run "aws s3 sync --debug --delete s3://#{bucket}/upload/production #{upload_path}"
    run ". #{current_path}/.env && PGPASSWORD=$CMS_DB_PWD psql -U $CMS_DB_USER -h localhost $CMS_DB < #{deploy_path}/shared/upload/cms.sql"
    run "cd #{current_path} && bundle exec rake db:migrate RAILS_ENV=#{env}"
    run "cd #{current_path} && bundle exec rake searchkick:reindex:all RAILS_ENV=#{env}"
  end

  def dump_time
    file = storage.files('upload/production/cms.sql').first
    file&.last_modified
  end
end
