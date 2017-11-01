require 'active_support/concern'
module DocumentSetSearch
  extend ActiveSupport::Concern

  included do
    searchkick highlight: [:title, :files, :contract, :documents, :questions, :answers],
               batch_size: 5
  end

  def files_to_index
    if pdf
      [pdf]
    else
      document_files
    end
  end

  def search_data
    attributes.merge(
        #files: files_data,
        contract: contract_data,
        documents: documents_data,
        questions: questions_data,
        answers: answers_data,
        original_text: original_text_data,
        order_item_ids: order_item_ids,
        subscriber_ids: subscriber_ids
    )
  end

  private

  def files_data
    # Split by pages because ElasticSearch has the 32K limit for a single string field.
    result = files_to_index.map do |file_link|
      [file_link.file_filename] +
          file_link.file_text.to_s.split(FileLink::PAGE_SEPARATOR)
    end
    result.flatten.compact.join(FileLink::PAGE_SEPARATOR).split(FileLink::PAGE_SEPARATOR)
  end

  def answers_data
    result = question_links.map { |q| q.answer }
    result += ds_questions.map { |ds_question| ds_question.question_link.answer }
    result += ds_questions.map(&:answer)
    result.flatten.compact
  end

  def questions_data
    result = questions.map { |q| q.text }
    result += ds_questions.map { |ds_question| ds_question.question_link.question.text }
    result.flatten.compact
  end

  def documents_data
    documents.map { |doc| Array(doc.try(:attributes)) }
  end

  def contract_data
    Array(contract.try(:attributes)).flatten.compact
  end

  def original_text_data
    result = ds_questions.map { |ds_question| ds_question.question_link.original_text }
    result += question_links.map { |q| q.original_text }
    result.flatten.compact
  end

  module ClassMethods
    def search_for(query, customer_id:, subscriber_ids: nil, page: 1)
      fields = DocumentSet.column_names.map &:to_sym
      fields += [:files, :contract, :documents, :questions, :answers, :original_text]

      search_params = {
          fields: fields,
          highlight: {tag: "<strong>"},
          page: page, per_page: 25,
          where: {customer_id: customer_id,
                  state: 'published'},
          misspellings: false
      }
      compact_subscriber_ids = Array(subscriber_ids).map{|u| u.present? ? u.to_i : nil }.compact
      search_params[:where][:subscriber_ids] = compact_subscriber_ids if compact_subscriber_ids.any?

      query = '*' if query == '' && subscriber_ids
      search_results = DocumentSet.search query, search_params
    end
  end
end
