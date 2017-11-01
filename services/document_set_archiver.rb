class DocumentSetArchiver

  def archive_expired
    ActiveRecord::Base.transaction do
      DocumentSet.active.expired.each do |docset|
        docset.archive!
      end
    end
  end
end
