module ActiveAdmin
  class ActivityPolicy < ApplicationPolicy
    def index?
      user.admin?
    end

    def show?
      user.admin? || user.power_user?
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
