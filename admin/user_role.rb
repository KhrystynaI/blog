ActiveAdmin.register UserRole do
  menu label: 'User Roles', parent: 'System'

  permit_params :title, :description
  actions :all, except: [:show, :destroy, :new]
  config.filters = false
  config.clear_action_items! # disable the "New Resource" link in the upper-right corner

  index do
    column :name
    column :title
    column :description
    actions
  end
end
