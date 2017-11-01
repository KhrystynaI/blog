ActiveAdmin.register ContractOwner do
  menu label: 'Contract owners', parent: 'Data'
  actions :all, except: [:show]
  permit_params :name, :address

  index do
    column :name
    column :address
    actions
  end

  filter :name
  filter :address

  form do |f|
    f.inputs 'Document Type Details' do
      f.input :name
      f.input :address
    end
    f.actions
  end
end
