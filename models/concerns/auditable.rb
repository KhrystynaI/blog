require 'active_support/concern'

module Auditable
  extend ActiveSupport::Concern

  included do
    include PublicActivity::Model
    tracked owner: ->(controller, _) { controller&.current_user },
            parameters: ->(_, model) do
              Hash(changes: model.changes, attributes: model.attributes)
            end
  end
end
