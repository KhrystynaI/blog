module ActiveAdmin
  class ContractPolicy < ApplicationPolicy
    include DocumentPolicyActions

    def update?
      true
    end
  end
end
