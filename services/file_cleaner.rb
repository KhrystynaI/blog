class FileCleaner

  def initialize(path_pattern: default_pattern)
    @path_pattern = path_pattern
  end

  def disk_files
    disk_files_map.keys
  end

  def db_files
    FileLink.pluck(:file_id)
  end

  def db_orphans
    db_files - disk_files
  end

  def disk_orphans
    disk_files - db_files
  end

  def file_link_orphans
    FileLink.all.select do |file_link|
      file_link.subject.nil?
    end
  end

  def status
    {
        disk_files: disk_files.count,
        db_files: db_files.count,
        disk_orphans: disk_orphans.count,
        db_orphans: db_orphans.count
    }
  end
  
  def disk_cleanup!
    disk_orphans.each do |file|
      File.delete disk_files_map[file]
    end
  end

  def db_cleanup!
    db_orphans.each do |file_id|
      FileLink.find_by(file_id: file_id).destroy
    end
  end

  def cleanup!
    disk_cleanup!
    db_cleanup!
  end
  
  private

  def default_pattern
    File.join(Rails.root, 'upload/store/*')
  end
  
  def disk_files_map
    disk_file_names = Dir.glob(@path_pattern)
    Hash[disk_file_names.map{|f| [File.basename(f), f] }]
  end
end
