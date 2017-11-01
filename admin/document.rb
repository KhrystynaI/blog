require 'data_import/documents/importer'

ActiveAdmin.register Document do
  decorate_with DocumentDecorator

  menu :label => 'Documents', priority: 1

  permit_params :doc_id, :document_type_name, :title, :version, :parent_id, :expiry_date,
                :customer_id, :tag_list, file_links_files: []
  actions :all, except: [:show]

  # scope_to :current_user
  scope :active, default: true
  scope :archived

  member_action :add_universal_questions, method: :post

  member_action :edit do
    @page_title = "#{resource.title} #{resource.version}"
  end

  member_action :archive do
    resource.archive!
    redirect_to admin_documents_path(scope: :archived), flash: {notice: 'Document has been archived.'}
  end

  member_action :restore do
    resource.restore!
    redirect_to admin_documents_path, flash: {notice: 'Document has been restored.'}
  end

  collection_action :selection_list, method: :get do
    filter = {}
    filter[:doc_id] = params[:doc_id] if params[:doc_id].present?
    filter[:version] = params[:version] if params[:version].present?
    filter[:state] = params[:state] if params[:state].present?
    filter[:document_type_name] = params[:document_type] if params[:document_type].present?

    query = Document.where(filter).text_search(params[:title])
    @total = query.count
    @documents =query.page(params[:pageIndex]).per(params[:pageSize])
  end

  action_item(:import, :only => :index) do
    link_to('Import Files', action: 'import') if authorized? :import, Document
  end

  action_item(:import_reports, only: :index) do
    link_to('View Import Reports', admin_import_reports_path({scope: :imports_documents})) if authorized? :import, Document
  end

  collection_action :import, method: [:get, :post] do
    authorize! :import, Document
    if request.post?
      begin
        activity = DocumentImporter.new.perform(user: current_user,
                                                need_backup: request[:backup] == 'yes')

        redirect_to admin_import_report_path(activity.id),
                    flash: {notice: 'Import complete.'}
      rescue => error
        Rails.logger.error "Error importing files: #{error.message}"
        redirect_to :back, flash: {
          error: 'Sorry, this file cannot be imported. Please contact support for help.'}
      end
    end
  end

  index do

    selectable_column
    column 'Doc ID', :doc_id
    column :customer
    column 'Modified', :updated_at

    column :type do |document|
      document.document_type.try(:title)
    end
    column 'Title', :file_preview_link_or_title
    column :version
    column :tag_list

    actions(defaults: false) do |doc|
      links = []

      links << link_to('Edit', edit_admin_document_path(doc),
                       class: 'edit_link member_link')

      if doc.archived?
        links << link_to('Restore', restore_admin_document_path(doc), class: 'unarchive_link member_link')
      else
        links << link_to('Archive', archive_admin_document_path(doc), class: 'archive_link member_link')
      end

      # Delete
      if doc.archived?
        confirmation_msg = <<~MSG
          You are going to delete the document  '#{CGI.escapeHTML doc.display_title}'.
          Are you sure?
        MSG

        links << link_to('Delete',
                         admin_document_path(doc), method: :delete,
                         data: {confirm: confirmation_msg},
                         class: 'delete_link member_link')
      end

      links.join('<br/>').html_safe
    end
  end

  filter :doc_id, label: 'Document ID', filters: [:equals, :contains]
  filter :document_type_name, as: :select, collection: -> { DocumentType.all }
  filter :title
  filter :customer
  filter :tags
  filter :archived
  filter :created_at, label: 'Created'
  filter :updated_at, label: 'Modified'

  form partial: 'form'

  controller do
    include ActiveAdmin::ControllerHelper

    def new
      if params[:version]
        @document = create_new_version(params)
      else
        @document = Document.new
        @document.fill_new_document
      end
    end

    def create
      if params[:version]
        @document = create_new_version(params)
      else
        @document = Document.new(document_params)
      end

      if @document.save
        redirect_to edit_admin_document_path(resource), notice: 'Document has been created.'
      else
        render :new
      end
    end

    def update
      # if not multiple choose of files, then we have to make the array, for correct upload
      if params[:document]["file_links_files"] && params[:document]["file_links_files"].class.name != 'Array'
        file = params[:document]["file_links_files"]
        params[:document]["file_links_files"] = ["[{},{},{}]", file]
      end
      if resource.update(document_params)
        if params[:document]["file_links_files"]
          redirect_to edit_admin_document_path(resource, anchor: 'files'),
                      flash: {notice: 'File(s) added successfully.'}
        else
          redirect_to admin_documents_path, notice: 'Document has been updated.'
        end
      else
        render :edit
      end
    end

    private

    def create_new_version(params)
      @document = Document.new
      # filling new vershion of the document with params from perent
      # (version, doc_id, document_type)
      @document.version = params[:version]
      parent = Document.find_by(id: params[:parent_id])
      @document.copy_version_attributes(parent)
      @document
    end

    def document_params
      @_document_params ||= permitted_params.require(:document).permit(
        :doc_id, :document_type_name, :title, :version, :customer_id,
        :expiry_date, :tag_list, file_links_files: [])
    end

  end
end
