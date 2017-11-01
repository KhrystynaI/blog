module ActiveAdmin
  class DocumentSetPolicy < ApplicationPolicy
    def update?
      user.admin? ||
        (user.power_user? && !PermissionException.exists?(user_id: user.id, doc_id: record.doc_id)) ||
        (user.editor? && EditorPermission.exists?(user_id: user.id, doc_id: record.doc_id))
    end

    def copy?
      update?
    end

    def complete?
      update?
    end

    def publish?
      update?
    end

    def withdraw?
      user.admin?
    end

    def archive?
      update?
    end

    def restore?
      archive?
    end

    def selection_list?
      true
    end

    def select_users?
      true
    end

    def change_vendor?
      true
    end

    def copy_questions?
      update?
    end

    def update_documents?
      update?
    end

    def add_documents?
      update?
    end

    def add_custom_question?
      update?
    end

    def add_universal_questions?
      update?
    end
  end
end
