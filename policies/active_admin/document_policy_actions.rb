require 'active_support/concern'
module ActiveAdmin
  module DocumentPolicyActions
    extend ActiveSupport::Concern

    def complete?
      update?
    end

    def publish?
      update?
    end

    def withdraw?
      update?
    end

    def archive?
      update?
    end

    def restore?
      archive?
    end

    def copy?
      true
    end
  end
end
