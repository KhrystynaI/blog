class DocumentSetCopier
  attr_reader :source, :copy_documents, :copy_questions, :copy_answers, :renew_orders

  def self.create_new_version(source, version: version,
      copy_documents: false, copy_questions: false, copy_answers: false, renew_orders: false)
    self.new(source: source, target: DocumentSet.new(version: version),
             copy_documents: copy_documents,
             copy_questions: copy_questions,
             copy_answers: copy_answers,
             renew_orders: renew_orders).perform
  end

  def initialize(source:, target:,
                 copy_documents:, copy_questions:, copy_answers:, renew_orders:)
    @source = source
    @target = target

    @copy_documents = copy_documents
    @copy_questions = copy_questions
    @copy_answers = copy_answers
    @renew_orders = renew_orders
  end

  def perform
    ActiveRecord::Base.transaction do

      @target.copy_version_attributes(@source)
      @target.save!

      if @copy_documents
        @target.contract = source.contract
        @target.documents << source.documents
      end

      if @copy_questions
        QuestionsCopier.copy_questions_and_answers(
            source: @source, target: @target, with_answers: @copy_answers)
      end

      if @renew_orders
        copy_orders
      end

      @target.save!
    end

    @target
  end


  def create_new_version(params)
    @document_set = DocumentSet.new
    # filling new vershion of the document with params from perent
    # (version, doc_id, ...)
    @document_set.version = params[:version]
    parent = DocumentSet.find_by(id: params[:parent_id])

    @document_set
  end

  def copy_orders(shift_by: 1.year)
    @target.order_items <<
        @source.order_items.active.map do |order_item|
          new_order_item = OrderItem.new(
              subscriber: order_item.subscriber,
              order_id: order_item.order_id,
              expiry_date: (order_item.expiry_date || Date.today) + shift_by
          )
        end
  end
end
