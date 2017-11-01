ActiveAdmin.register Setting do
  menu label: 'Settings', parent: 'System', priority: 99

  actions :all, except: [:destroy, :new]
  config.clear_action_items! # disable the "New Resource" link in the upper-right corner
  config.sort_order = 'name_asc'

  permit_params :value

  filter :section, as: :select, collection: -> { Setting.sections }
  filter :name

  index do
    column :section
    column :name
    column :value
    actions
  end

  form do |f|
    attributes_table_for resource do
      row :name
      row :description
    end
    f.inputs 'Edit' do
      f.input :value
    end
    f.actions
  end
end
