ActiveAdmin.register PermissionException do
  menu label: 'Permission Exceptions', parent: 'Permissions'

  actions :all, except: [:show]
  permit_params :doc_id, :user_id

  config.batch_actions = true

  index title: 'Power User Permission Exceptions' do
    selectable_column
    column('Poswer User', :user) {|i| i.user.full_name}
    column 'DocSet ID', :doc_id
    actions
  end

  form do |f|
    f.inputs 'Prevent the user editing the DocumentSet below' do
      f.input :user, label: 'Power User',  as: :select, collection: User.power_users.collection.invert
      f.input :doc_id, label: 'DocSet ID', as: :select, collection: DocumentSet.doc_ids
    end
    f.actions
  end

  filter :doc_id, label: 'DocSet ID'
  filter :user, as: :select, collection: -> { User.power_users.collection.invert }

  controller do
    def scoped_collection
      end_of_association_chain.joins(:user).where('users.role': 'power_user')
    end
  end
end
