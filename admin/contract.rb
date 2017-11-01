ActiveAdmin.register Contract do
  menu :label => 'Contracts' #, priority: 1

  permit_params :doc_id, :title, :contract_owner_id, :version, :start_date, :end_date, :duration, :expiry_date,
                :tag_list, :price, :phone, fields_attributes: [:id, :title, :value, :_destroy], file_links_files: []

  actions :all, except: [:show]

  member_action :publish, method: :post do
    resource.state = 'published'
    resource.save!
    redirect_to edit_admin_contract_path(resource), flash: {notice: "Contract has been published."}
  end

  member_action :withdraw, method: :post do
    resource.state = 'in_progress'
    resource.save!
    redirect_to edit_admin_contract_path(resource),
                flash: {notice: "Contract is now in progress."}
  end

  member_action :archive do
    @contract = Contract.find_by(id: params[:id])
    @contract.archive!
    redirect_to admin_contracts_path(scope: :archived), flash: {notice: 'Contract has been archived.'}
  end

  member_action :restore do
    @contract = Contract.find_by(id: params[:id])
    @contract.restore!
    redirect_to admin_contracts_path, flash: {notice: 'Contract has been restored.'}
  end

  collection_action :selection_list, method: :get do
    filter = {}
    filter[:state] = params[:contract_state] if params[:contract_state].present?
    @contracts = Contract.where(filter).text_search(params[:q]).page(params[:page]).per(10)
  end

  scope :active, default: true
  scope :archived

  index do

    selectable_column
    column 'Contract ID', :doc_id
    column :state do |d|
      doc_status_tag d
    end
    column 'Created', :created_at
    column 'Modified', :updated_at
    column :title
    # column :version_list do |contract|
    #   string = generate_version_links(contract.versions)
    # end
    column :vendor do |doc|
      doc.vendor.try(:name)
    end
    column :product do |doc|
      doc.product.try(:name)
    end
    column :tag_list


    actions(defaults: false) do |doc|
      links = []

      links << link_to('Edit', edit_admin_contract_path(doc),
                       class: 'edit_link member_link')

      if doc.archived?
        links << link_to('Restore', restore_admin_contract_path(doc), class: 'unarchive_link member_link')
      else
        links << link_to('Archive', archive_admin_contract_path(doc), class: 'archive_link member_link')
      end

      # Delete
      if doc.archived?
        confirmation_msg = <<~MSG
          You are going to delete the contract  '#{CGI.escapeHTML doc.display_title}'.
          Are you sure?
        MSG

        links << link_to('Delete',
                         admin_contract_path(doc), method: :delete,
                         data: {confirm: confirmation_msg},
                         class: 'delete_link member_link')
      end

      links.join('<br/>').html_safe
    end
  end

  filter :doc_id, title: 'Contract ID', filters: [:equals, :contains]
  filter :title
  filter :expiry_date
  filter :price
  filter :phone
  filter :created_at, label: 'Created'
  filter :updated_at, label: 'Modified'
  filter :tags


  form partial: 'form'

  controller do
    include ActiveAdmin::ControllerHelper

    def new
      @contract = Contract.new
      if params[:version]
        # filling new vershion of the contract with params from perent
        # (version, doc_id, document_type)
        @contract.version = params[:version]
        parent = Contract.find_by(id: params[:parent_id])
        @contract.copy_version_attributes(parent)
      else
        @contract.fill_new_document
      end
    end

    def create
      @contract = Contract.new(contract_params)
      if @contract.save
        redirect_to edit_admin_contract_path(resource), notice: 'Contract has been created.'
      else
        render :new
      end
    end

    def update
      if resource.update(contract_params)
        if params[:contract]["file_links_files"]
          redirect_to edit_admin_contract_path(resource, anchor: 'files'),
                      flash: {notice: 'File(s) added successfully.'}
        else
          redirect_to admin_contracts_path, notice: 'Contract has been updated.'
        end
      else
        render :edit
      end
    end

    private

    def contract_params
      permitted_params.require(:contract).permit(:doc_id, :title, :contract_owner_id, :version, :start_date, :end_date, :duration, :expiry_date,
                                                 :tag_list, :price, :phone, fields_attributes: [:id, :title, :value, :_destroy], file_links_files: [])
    end

  end
end
