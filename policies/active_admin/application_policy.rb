module ActiveAdmin
  class ApplicationPolicy
    attr_reader :user, :record

    class Scope < Struct.new(:user, :scope)
      def resolve
        scope
      end
    end

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index?
      true
    end

    def show?
      true #scope.where(id: record.id).exists?
    end

    def new?
      create?
    end

    def create?
      update?
    end

    def edit?
      update?
    end

    def update?
      true
    end

    def destroy?
      update?
    end

    def destroy_all?
      update?
    end

    def scope
      Pundit.policy_scope!(user, record.class)
    end
  end
end
