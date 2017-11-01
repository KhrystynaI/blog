module ActiveAdmin
  class ActivityReportPolicy < ApplicationPolicy
    def index?
      true
    end

    def show?
      true
    end

    def create?
      false
    end

    def update?
      false
    end

    def destroy?
      false
    end

    def destroy_all?
      false
    end
  end
end
