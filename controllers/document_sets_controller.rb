require 'pdf/combiner'
require 'sanitize'
class DocumentSetsController < ApplicationController
  before_action :require_customer, except: 'welcome'
  before_action :authorize, except: 'welcome'
  before_action :remember_page_count, only: 'index'
  before_action :assign_user, only: %w(search preview pdf ops)
  before_action :assign_docset, only: %w(preview pdf ops)
  before_action :assign_one_page_summary, only: %w(preview ops)

  def index
    scoped_documents = DocumentSet.where(customer: current_customer).active.published.order('title')
    @total = scoped_documents.count
    @document_sets = scoped_documents.page(params[:page]).per(session[:per_count] || 25)
  end

  def preview
    if @document_set.one_page? && @document_set.pdf.nil?
      @document_set.generate_pdf
    end

    respond_to do |format|
      format.html
      format.pdf do
        return render pdf: @document_set.filename, layout: 'pdf.html'
      end
    end
  end

  def ops
    respond_to do |format|
      format.html do
        render template: 'document_sets/preview.pdf',
               layout: 'pdf.html',
               encoding: 'UTF-8'
      end
      format.pdf do
        # generate pdf
        pdf = render_to_string pdf: @document_set.filename,
                               template: 'document_sets/preview.pdf',
                               layout: 'pdf.html',
                               encoding: 'UTF-8'

        # save to a file
        file_path = Rails.root.join('tmp', "#{@document_set.filename}.pdf")
        File.open(file_path, 'wb') do |file|
          file << pdf
        end

        # concatenate
        pdf = Pdf::Combiner.combine_ops(file_path, @document_set.files)

        ops_file_path = Rails.root.join('tmp', "#{@document_set.filename}-ops.pdf")
        pdf.save ops_file_path

        # render file
        send_file ops_file_path,
                  filename: "#{@document_set.filename}.pdf",
                  type: 'application/pdf'
      end
    end
  end

  # applicable only for OPS created manually
  def pdf
    @document_set.generate_pdf unless @document_set.pdf

    send_data @document_set.pdf,
              :filename => "#{@document_set.filename}.pdf",
              :type => "application/pdf"
  end

  def search
    @query = params[:q] # display query value back in the search field rendering results

    @search_results = DocumentSet.search_for(@query.to_s,
                                             customer_id: current_customer.id,
                                             subscriber_ids: @user_id,
                                             page: (params[:page] || 1))
  end

  def welcome
    if current_customer
      redirect_to search_path(current_customer)
    else
      redirect_to sessions_new_path, notice: 'Please select customer to continue.'
    end
  end

  def find_subscriber
    users = User.customer(current_customer.id).search(params[:name]).limit(20)
    #raise ActiveRecord::RecordNotFound unless users.count == 1

    if users.count == 1
      user = users.first
      result = {id: user.id, name: user.name}
    else
      result = {}
    end

    render json: result
  end

  private

  def assign_user
    @user_id = (params[:user_id].to_s.gsub('"', '').to_i rescue nil)
    @user_id = nil if @user_id == 0
    @user = User.find_by(id: @user_id) if @user_id
  end

  def assign_docset
    @document_set = DocumentSet.find_by(id: params.require(:id))
  end

  def assign_one_page_summary
    @order_item = @document_set.order_items.detect { |item| item.subscriber_id == @user_id } if @user_id

    @questions_categories = @document_set.all_questions_answers.group_by { |d| d[:category] }
    @file_links = []
    @document_set.documents.each do |document|
      document.file_links.each do |file|
        @file_links << file
      end
    end
    if @document_set.contract
      @document_set.contract.file_links.each do |file|
        @file_links << file
      end
    end
  end

  def remember_page_count
    per_page = params[:per_page]
    if per_page
      if per_page == 'all'
        session[:per_count] = 999999
      else
        session[:per_count] = per_page.to_i
      end
    end
  end

  def require_customer
    redirect_to sessions_new_path, notice: 'Please select customer!' unless current_customer
  end

  def authorize
    if current_customer.access_key != current_access_key
      redirect_to sessions_new_path, notice: 'Please specify access key.'
    end
  end
end
