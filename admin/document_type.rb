ActiveAdmin.register DocumentType do
  menu label: 'Document Types', parent: 'Data', priority: 1
  actions :all, except: [:show]
  permit_params :name, :title, :description, :metadata

  index do
    column :name
    column :title
    column :description
    column :metadata
    actions
  end

  form do |f|
    f.inputs 'Document Type Details' do
      f.input :name
      f.input :title
      f.input :description
      f.input :metadata
    end
    f.actions
  end
end
