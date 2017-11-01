module DocumentStatus
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

  def start!
    self.state = 'in_progress'
    resource.save!
  end

  def complete!
    self.state = 'complete'
    resource.save!
  end

  def publish!
    self.state = 'published'
    save!
  end

  def withdraw!
    self.state = 'in_progress'
    save!
  end

  def restore!
    self.state = 'in_progress'
    save!
  end

  def archive!
    self.state = 'archived'
    save!
  end

end
