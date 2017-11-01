ActiveAdmin.register Question, parent: 'Questions' do
  menu label: 'Questions', parent: 'Questions'
  actions :all, except: [:show]

  filter :category_id, as: :select, collection: proc { QuestionCategory.all }
  filter :text, label: 'Title'

  scope :standard, default: true
  scope :custom
  scope :deleted

  permit_params :category_id, :text, :note, :custom

  config.sort_order = 'position_asc'

  index as: :table do |table|
    questions_categories = groupify_questions_for_list(object.questions)
    render partial: 'admin/questions/question_index', locals: {questions_categories: questions_categories}
  end

  controller do
    private

    def reorderable_column(dsl)
      # Don't allow reordering if filter(s) present
      # or records aren't sorted by `order`
      # return if params[:q].present? || params[:order] != "order"

      dsl.column('Reorder', sortable: false) do
        dsl.fa_icon :arrows, class: "js-reorder-handle"
      end
    end

    helper_method :reorderable_column
  end

  form do |f|
    inputs do
      input :custom
      input :category
      input :note
      input :text
    end
    actions
  end

  collection_action :reorder, method: :patch do
    positions = params.require(:positions)

    resource_class.transaction do
      positions.each do |id, hash|
        item = resource_class.find_by(id: id)
        new_position = hash[:position].to_i + 1
        item.update_column(:position, new_position) if item.position != new_position
      end
      current_user.create_activity(:reorder, parameters: {collection: resource_class})
    end

    render json: {status: "success"}
  end

  member_action :restore, method: :post do
    resource.restore
    redirect_to :back, notice: 'Question has been restored.'
  end
end
