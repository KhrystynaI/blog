ActiveAdmin.register_page 'Data' do
  menu label: 'Data', priority: 99, url: '#'
end

ActiveAdmin.register Customer do
  actions :all, except: [:show]
  menu label: 'Customer List', parent: 'Data'
  permit_params :name, :path, :access_key

  member_action :add_universal_questions, method: :post
  member_action :add_custom_question, method: :post

  config.sort_order = 'name_asc'
  index do
    id_column
    column :name
    column :path
    column :access_key
    actions do |customer|
      double_link = ""
      double_link += link_to 'Search', search_path(customer, access_key: customer.access_key), class: 'search_link member_link'
      double_link.html_safe
    end
  end

  filter :name
  filter :path
  filter :access_key

  form partial: 'form'

  controller do
    include ActiveAdmin::ControllerHelper

    def create
      @customer = Customer.new(customer_params)
      if @customer.save
        redirect_to edit_admin_customer_path(resource), notice: 'Customer has been created.'
      else
        render :new
      end
    end

    def find_resource
      Customer.find_by(path: params[:id])
    end

    def add_universal_questions
      customer = Customer.find_by(path: params[:id])

      tree_data = params[:tree_data]
      question_ids = extract_fancy_tree_selected_questions(tree_data)
      customer.link_questions(question_ids)

      redirect_to edit_admin_customer_path(customer, anchor: 'questions'),
                  flash: { notice: 'Question(s) added successfully.'}
    end

    def add_custom_question
      customer = Customer.find_by(path: params[:id])

      permited = params.require(:question).permit(:text, :category_id)

      begin
        customer.add_custom_question(text: permited[:text],
          category_id: permited[:category_id])

        redirect_to edit_admin_customer_path(customer, anchor: 'questions'),
                    flash: { notice: 'Question added successfully.'}
      rescue => error
        redirect_to edit_admin_customer_path(customer, anchor: 'questions'),
                    flash: { error: error.message }
      end
    end

    private

    def customer_params
      permitted_params.require(:customer).permit(:name, :path, :access_key)
    end

  end
end
