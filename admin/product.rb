ActiveAdmin.register Product do
  menu label: 'Product List', parent: 'Data'
  actions :all, except: [:show]
  permit_params :name, :note, :vendor_id

  config.sort_order = 'name_asc'
  index do
    column :name
    column :note
    column :vendor
    actions
  end

  filter :name
  filter :vendor

  form do |f|
    f.inputs 'Document Type Details' do
      f.input :name
      f.input :note
      f.input :vendor
    end
    f.actions
  end
end
