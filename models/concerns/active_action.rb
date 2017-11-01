require 'active_support/concern'

module ActiveAction
  extend ActiveSupport::Concern

  def active_actions
    @active_actions ||= []
  end

  def active_action
    active_actions.last
  end

  def performing(action_name, &block)
    active_actions.push(action_name)
    yield
  ensure
    active_actions.pop
  end
end
