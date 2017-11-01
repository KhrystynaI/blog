ActiveAdmin.register Vendor do
  menu label: 'Vendor List', parent: 'Data'
  actions :all, except: [:show]

  permit_params :name, :parent_company, :location, :terms_source, :terms_link, :notes

  config.sort_order = 'name_asc'
  index do
    column :name
    column 'Parent Company', :parent_company
    column :location
    column 'T&C source', :terms_source
    column 'T&C link', :terms_link
    column :notes
    actions
  end

  filter :name
  filter :products
  filter :parent_company
  filter :location
  filter :terms_source
  filter :terms_link
  filter :notes

  form partial: 'form'

  # form do |f|
  #   f.inputs 'Vendor Details' do
  #     f.input :name
  #     f.input :products
  #     f.input :parent_company
  #     f.input :location
  #     f.input :terms_source
  #     f.input :terms_link
  #     f.input :notes
  #   end
  #   f.actions
  # end
end
