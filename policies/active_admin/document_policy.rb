module ActiveAdmin
  class DocumentPolicy < ApplicationPolicy
    include DocumentPolicyActions

    def update?
      true
    end

    def import?
      true
    end
  end
end
