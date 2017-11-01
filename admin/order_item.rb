require 'data_import/orders/importer'
ActiveAdmin.register OrderItem do
  menu label: 'Orders'

  actions :all, except: [:new, :show]
  config.batch_actions = true

  scope :active, default: true
  scope :archived

  index do
    selectable_column
    column :document_set do |i|
      link_to(i.document_set.name, edit_admin_document_set_path(i.document_set_id),
              target: '_subscription') if i.document_set
    end
    column :order_id
    column :expiry_date
    column(:first_name) { |i| i.subscriber.try(:first_name) }
    column(:last_name) { |i| i.subscriber.try(:last_name) }
    column(:address) { |i| i.subscriber.try(:address) }
    column(:created_at)
    column(:updated_at)
    column(:state)
    column('Active', as: '') { |i| status_tag(i.active? ? 'Yes' : 'No') }
    actions
  end

  filter :order_id
  filter :expiry_date
  filter :subscribers
  filter :document_set
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs 'Subscriber Info', for: :subscriber do |s|
      s.input :brid, label: 'Employee ID'
      s.input :first_name
      s.input :last_name
      s.input :address
    end

    f.inputs 'Document Type Details' do
      f.input :return_to, :input_html => {:value => params[:return_to], name: 'return_to'}, as: :hidden
      f.input :order_id, label: 'Order ID'
      f.input :expiry_date, as: :datepicker
      f.input :state, as: :select, collection: %i(new renewal)
      f.input :archived
    end
    f.actions
  end

  action_item(:import, :only => :index) do
    link_to('Import Orders', action: 'import')
  end

  action_item(:import_reports, only: :index) do
    link_to('View Import Reports', admin_import_reports_path({scope: :imports_subscriptions}))
  end

  # /admin/subscriptions/import
  collection_action :import, method: [:get, :post] do
    if request.post?
      begin
        if request[:backup] == 'yes'
          current_user.create_activity(:backup)
          BackupService.backup
        end

        csv = params.fetch(:csv)
        customer_id = csv.fetch(:customer_id)
        file_path = csv.fetch(:file).tempfile.path

        importer = DataImport::Orders::Importer.import_csv_file(file_path, customer_id: customer_id)
        activity = current_user.create_activity(:import_subscriptions,
                                                parameters: {results: importer.results})
        redirect_to  admin_import_report_path(activity.id),
                     flash: {notice: 'Import complete.'}
      rescue => error
        error_message = "Could not import CSV file. #{error.message}. \n"\
          "Please check file format is correct or contact developers."
        redirect_to :back, flash: {error: error_message}
      end
    end
  end

  controller do
    def update
      update! do |format|
        format.html do
          if resource.errors.any?
            redirect_to redirect_path, flash: {
                error: "Order Item has not been updated: " + resource.errors.full_messages.join(", ")}
          else
            redirect_to redirect_path
          end
        end
      end

    end

    after_update do
      resource.document_set.touch
    end

    def destroy
      redirect_path = params[:redirect_to].present? ? params[:redirect_to] : :back

      destroy! do |format|
        format.html do
          redirect_to redirect_path, notice: 'Order Item was successfully deleted.'
        end
      end
    end

    def create
      if params[:order_item][:subscriber_id].present?
        params[:order_item].delete(:subscriber_attributes)
      else
        customer_id = DocumentSet.where(id: params[:order_item].require(:document_set_id)).pluck(:customer_id).first
        customer = Customer.find_by!(id: customer_id)
        fake_subscriber_email = -> (first_name, last_name) do
          "#{first_name.parameterize}.#{last_name.parameterize}@#{customer.path}-example.com"
        end

        params[:order_item][:subscriber_attributes][:email] =
            fake_subscriber_email[params[:order_item][:subscriber_attributes][:first_name],
                                  params[:order_item][:subscriber_attributes][:last_name]]

        params[:order_item][:subscriber_attributes][:password] = '12345678'

        params[:order_item][:subscriber_attributes][:customer_id] = customer_id
        params[:order_item][:subscriber_attributes][:role] = 'subscriber'
      end

      create! do |format|
        format.html do
          if resource.errors.any?
            redirect_to redirect_path, flash: {
                error: "Order Item has not been created: " + resource.errors.full_messages.join(", ")}
          else
            redirect_to redirect_path, notice: "Order Item #{resource.order_id} has been created."
          end
        end
      end
    end

    def redirect_path
      if params[:return_to].present?
        params[:return_to]
      else
        :back
      end
    end

    def permitted_params
      params.permit order_item: [:order_id, :expiry_date, :subscriber_id, :document_set_id,
                                 subscriber_attributes:
                                     [:id, :brid, :first_name, :last_name, :address, :email, :password,
                                      :customer_id, :role]]
    end

    def apply_filtering(chain)
      @search = chain.ransack clean_search_params
      @search.result(distinct: true)
    end
  end
end
