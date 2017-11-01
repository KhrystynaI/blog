ActiveAdmin.register Tag do
  menu label: 'Tags', parent: 'Data'

  actions :all, except: [:show]
  permit_params :name

  config.sort_order = 'name_asc'

  filter :name

  index do
    selectable_column
    column :name
    actions
  end

  form do |f|
    f.inputs 'Tag' do
      f.input :name
    end
    f.actions
  end

end
