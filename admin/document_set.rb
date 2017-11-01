require 'data_import/doc_set_ids/importer'
require 'sanitize'
require_relative 'document_sets/filters'
require_relative 'document_sets/batch_actions'

include ActiveAdmin::ViewHelper

ActiveAdmin.register DocumentSet do
  config.batch_actions = true

  include Admin::DocumentSets::Filters
  include Admin::DocumentSets::BatchActions

  permit_params :doc_id, :title, :version, :tag_list, :customer_id, :vendor_id, :product_id,
                :assigned_to, :contract_id, :document_ids
  actions :all, except: [:show]

  scope :active, default: true
  scope :archived
  scope :expired
  scope :expire_soon

  row_class = ->(docset) do
    case
      when docset.order_items_expired?
        'expired'
      when docset.order_items_expire_in?(4.months)
        'expire-soon'
    end
  end

  index row_class: row_class do
    selectable_column
    column 'Doc Set<br>ID'.html_safe, :doc_id
    column :state do |d|
      doc_status_tag d
    end
    column 'Date Published', :sortable => :published_at do |d|
      long_date_format(d.published_at) if d.published?
    end
    column 'Expiry date', :sortable => :expiry_date do |d|
      long_date_format(d.expiry_date)
    end
    column 'Modified', :updated_at
    column :customer
    column :assignee
    column :title
    column 'Ver', :version
    column :vendor do |docset|
      div(class: 'hint') do
        div(class: 'hinty') do
          text_node docset.vendor&.name
        end

        span(class: 'bubble', style: 'display: none;') do
          render 'admin/vendors/hint', vendor: docset.vendor
        end
      end if docset.vendor

      #edit_admin_vendor_path(docset.vendor), label: docset.vendor&.display_title) if docset.vendor
    end
    # column :version_list do |document_set|
    #   string = generate_version_links(document_set.versions)
    # end
    column :questions do |docset|
      docset.questions.count
    end
    #column :vendor
    #column :tag_list
    actions(defaults: false) do |doc_set|
      # can add just one additional link in block (that is passed to text_node)
      links = []
      policy = ActiveAdmin::DocumentSetPolicy.new(current_user, doc_set)
      links << link_to('Edit', edit_admin_document_set_path(doc_set),
                       class: 'edit_link member_link')

      # TODO test Preview link opens a Preview Page
      if doc_set.customer
        links << link_to('Preview',
                         preview_path(doc_set.customer.path, doc_set,
                                      access_key: doc_set.customer.access_key),
                         class: 'preview_link member_link', :target => "_blank")
      end
      # TODO test pdf link leads to pdf download
      if doc_set.pdf
        links << link_to('pdf', attachment_url(doc_set.pdf, :file),
                         :class => 'pdf_link member_link', :target => "_blank")
      end

      if doc_set.archived?
        links << link_to('Restore', restore_admin_document_set_path(doc_set),
                         class: 'unarchive_link member_link', method: :post) if policy.restore?
      else
        links << link_to('Archive', archive_admin_document_set_path(doc_set),
                         class: 'archive_link member_link', method: :post) if policy.archive?
      end

      # Delete
      if doc_set.archived?
        confirmation_msg = <<~MSG
          You are going to delete the document set '#{CGI.escapeHTML doc_set.name}'
          and related order items if any.
          Are you sure?
        MSG

        links << link_to('Delete',
                         admin_document_set_path(doc_set), method: :delete,
                         data: {confirm: confirmation_msg},
                         class: 'delete_link member_link')
      end

      links.join('<br/>').html_safe
    end
  end


  form partial: 'form'

  member_action :edit
  member_action :copy, method: :post
  member_action :add_universal_questions, method: :post
  member_action :add_custom_question, method: :post

  member_action :select_users

  member_action :complete, method: :post
  member_action :publish, method: :post
  member_action :complete, method: :post
  member_action :withdraw, method: :post, if: -> { current_user.admin? }
  member_action :copy_questions, method: :post
  member_action :archive, method: :post
  member_action :restore, method: :post
  member_action :add_documents, method: :post
  member_action :selection_list, method: :get

  collection_action :change_vendor
  collection_action :import_ids, method: [:get, :post]

  controller do
    include ActiveAdmin::ControllerHelper

    def publish
      resource.publish!
      redirect_to edit_admin_document_set_path(resource),
                  flash: {notice: "Document Set has been Published and can be viewed by users."}
    end

    def complete
      resource.complete!
      redirect_to edit_admin_document_set_path(resource),
                  flash: {notice: "Document Set is marked Complete."}
    end

    def withdraw
      resource.withdraw!
      redirect_to edit_admin_document_set_path(resource),
                  flash: {notice: "Document Set is now back in progress and cannot be viewed by end users."}
    end

    def copy_questions
      ActiveRecord::Base.transaction do
        PublicActivity.without_tracking do
          resource.question_links.destroy_all
          QuestionsCopier.copy_questions_and_answers(
            source: DocumentSet.find_by(id: params[:source_document_set_id]),
            target: resource, with_answers: true)
        end
        current_user.create_activity(:copy_questions,
                                     parameters: {source_docset: params[:source_document_set_id],
                                                  target_docset: resource.id})
      end
      render json: {status: 'Ok'}
    end

    def edit
      @contract_states = Contract::STATES
      @document_states = Document::STATES
      @document_types = DocumentType.all
      @document_set = DocumentSet.find_by(id: params[:id])
      @page_title = "#{@document_set.title} #{@document_set.version}"

      @document_set = resource
      @questions_categories = @document_set.all_questions_answers.group_by { |d| d[:category] }
    end

    def archive
      resource.archive!
      redirect_to admin_document_sets_path(scope: 'archived'),
                  flash: {notice: 'Document set has been archived.'}
    end

    def restore
      resource.restore!
      redirect_to admin_document_sets_path({scope: :archived}),
                  flash: {notice: 'Document set has been restored.'}
    end


    def add_documents
      documents = Document.where(id: params[:document_ids]).all
      ActiveRecord::Base.transaction do
        resource.documents << documents
      end

      render json: {status: 'Ok'}
    end

    def new
      @document_set = DocumentSet.new
      if params[:version]
        # filling new vershion of the document set with params from perent
        # (version, doc_id)
        @document_set.version = params[:version]
        parent = DocumentSet.find_by(parent_id: params[:parent_id])
        @document_set.copy_version_attributes(parent)
      else
        @document_set.fill_new_document_set
      end
    end

    def create
      @document_set = DocumentSet.new(document_set_params)
      if @document_set.save
        redirect_to edit_admin_document_set_path(resource), notice: 'Document set has been created.'
      else
        render :new
      end
    end

    def update
      ds_params = document_set_params
      if resource.update(document_set_params)
        if params[:document_set]["contract_id"]
          redirect_to edit_admin_document_set_path(resource, anchor: 'contract'),
                      flash: {notice: 'Document set is saved successfully.'}
        else
          redirect_to admin_document_sets_path, notice: 'Document set has been updated.'
        end
      else
        render :edit
      end
    end

    def destroy
      return redirect_to :back,
                         flash: {error: 'You can only delete Archived documents.'} \
                         unless resource.archived?

      if resource.destroy
        redirect_to admin_document_sets_path, notice: "Document set '#{resource.name}' has been deleted."
      else
        redirect_to :back, flash: {error: "Something weng wrong."\
          " Document set '#{resource.name}' has not been deleted."}
      end
    end

    def copy
      @document_set = DocumentSetCopier.create_new_version(resource,
        version: params[:version],
        copy_documents: params[:copy_documents],
        copy_questions: params[:copy_questions],
        copy_answers: params[:copy_answers],
        renew_orders: params[:renew_orders])

      redirect_to edit_admin_document_set_path(@document_set),
                  flash: {notice: 'Document set added successfully.'}
    rescue => error
      redirect_to edit_admin_document_set_path(resource),
                  flash: {error: "Error creating new version: #{error.message}"}
    end

    def add_universal_questions
      tree_data = params[:tree_data]
      question_document_comtract_array = extract_fancy_ds_tree_selected_questions(tree_data)
      resource.ds_link_questions(question_document_comtract_array)
      redirect_to edit_admin_document_set_path(resource, anchor: 'questions'),
                  flash: {notice: 'Question(s) added successfully.'}
    end

    def add_custom_question
      permited = params.require(:question).permit(:text, :category_id)

      raise 'Please fill in the question text.' if permited[:text].to_s.strip.blank?

      resource.add_custom_question(text: permited[:text],
                                   category_id: permited[:category_id])

      render json: {message: 'Question added successfully.'}
    rescue => error
      render json: {message: error.message}, status: 400
    end

    def document_set_params
      permitted_params.require(:document_set).permit(:doc_id, :title, :version, :tag_list, :customer_id,
                                                     :vendor_id, :product_id, :assigned_to, :contract_id)
    end

    def change_vendor
      respond_to do |format|
        if params[:vendor_id].blank?
          @products = []
        else
          @products = Product.where(vendor_id: params[:vendor_id])
        end
        format.js
      end
    end

    def selection_list
      filter = {}
      filter[:doc_id] = params[:doc_id] if params[:doc_id].present?
      filter[:version] = params[:version] if params[:version].present?
      query = DocumentSet.where.not(id: resource.id).where(filter).joins(
        "inner join question_links "\
        "on question_links.subject_type = 'DocumentSet' and question_links.subject_id = document_sets.id")
      query = query.pg_search(params[:title]) if params[:title].present?
      query = query.reorder("doc_id desc").uniq

      @total = query.count
      @document_sets =query.page(params[:pageIndex]).per(params[:pageSize])
    end

    def select_users
      users = User.where(customer_id: params[:customer_id]).text_search(params[:name]).page(params[:page]).per(10)
      raise ActiveRecord::RecordNotFound if users.count == 0

      result = users.map do |user|
        {id: user.id, name: user.name}
      end

      render json: result
    end
  end
end
