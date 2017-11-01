ActiveAdmin.register QuestionCategory do
  menu label: 'Question Categories', parent: 'Questions'
  actions :all, except: [:show]
  permit_params :name, :note

  config.sort_order = 'position_asc'

  index do
    reorderable_column(self)
    column :name
    column :note
    actions
  end

  form do |f|
    f.inputs 'Question Category Details' do
      f.input :name
      f.input :note
    end
    f.actions
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

  collection_action :reorder, method: :patch do
    positions = params.require(:positions)

    resource_class.transaction do
      positions.each do |id, position|
        item = resource_class.find_by(id: id)
        new_position = position.to_i + 1
        item.update_column(:position, new_position) if item.position != new_position
      end
      current_user.create_activity(:reorder, parameters: {collection: resource_class})
    end

    render json: { status: "success" }
  end

end
