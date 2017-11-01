module DocumentSetStatus
  extend ActiveSupport::Concern

  included do
    scope :archived, -> do
      where(state: 'archived')
    end

    scope :active, -> do
      where.not(state: 'archived')
    end

    scope :_new, -> do
      where(state: 'new')
    end

    scope :in_progress, -> do
      where(state: 'in_progress')
    end

    scope :published, -> do
      where(state: 'published')
    end
  end

  def new?
    state == 'new'
  end

  def in_progress?
    state == 'in_progress'
  end

  def complete?
    state == 'complete'
  end

  def published?
    state == 'published'
  end

  def archived?
    state == 'archived'
  end

  def start
    self.state = 'in_progress'
    self.published_at = nil
  end

  def start!
    start
    save!
  end

  def complete
    self.state = 'complete'
    self.published_at = nil
  end

  def complete!
    complete
    save!
  end

  def publish(save_record: true)
    self.state = 'published'
    self.published_at = Time.now
    save if save_record
    self
  end

  def publish!
    publish(save_record: false)
    save!
  end

  def withdraw!
    self.state = 'in_progress'
    self.published_at = nil
    save!
  end

  def restore!
    self.state = 'in_progress'
    self.published_at = nil
    save!
  end

  def archive!
    self.state = 'archived'
    save!
  end

end
