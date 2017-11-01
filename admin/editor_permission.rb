ActiveAdmin.register EditorPermission do
  menu label: 'Editor Permissions', parent: 'Permissions'

  actions :all, except: [:show]
  permit_params :doc_id, :user_id

  config.batch_actions = true

  index title: 'Editors are allowed to edit DocumentSets below' do
    selectable_column
    column(:user) {|i| i.user.full_name}
    column 'DocSet ID', :doc_id
    actions
  end

  form do |f|
    f.inputs 'Allow the user to edit the DocumentSet below' do
      f.input :user, as: :select, collection: User.editors.collection.invert
      f.input :doc_id,  label: 'DocSet ID',  as: :select, collection: DocumentSet.doc_ids
    end
    f.actions
  end

  filter :doc_id, label: 'DocSet ID'
  filter :user, as: :select, collection: -> { User.editors.collection.invert }

  controller do
    def scoped_collection
      end_of_association_chain.joins(:user).where('users.role': 'editor')
    end
  end
end
