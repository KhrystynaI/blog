module ActiveAdmin
  class UserPolicy < ApplicationPolicy
    def index?
      user.admin?
    end

    def update?
      user.admin? || user.id == record.id
    end

    def show?
      update?
    end

    def edit?
      update?
    end

    def create?
      user.admin?
    end

    def destroy?
      create?
    end

    def destroy_all?
      create?
    end
  end
end
