ActiveAdmin.register QuestionSet do
  actions :all, except: [:show]
  menu label: 'Question Sets', parent: 'Questions'

  permit_params :title

  member_action :add_universal_questions, method: :post

  index do
    id_column
    column :title
    actions
  end

  filter :title
  filter :questions, label: 'Contains Question'

  form do |f|
    tabs do
      tab 'Information' do
        f.inputs 'Question Set Details' do
          f.input :title
        end
        f.actions
      end

      tab 'Questions', name: 'questions' do
        columns id: 'questions-table', class: 'ui-tabs-panel ui-widget-content' do
          questions_categories = groupify_questions_for_list(object.questions)
          render partial: 'question_list',
                 locals: { questions_categories: questions_categories, questions_object: object }
        end

        columns class: 'actions' do
          questions_array = (Question.standard.all - object.questions)
          tree_data = groupify_questions_for_tree(questions_array, 'categories', false)
          render partial: 'add_universal_question', locals: { tree_data: tree_data, question_set: object }
        end
      end unless object.id.nil?
    end
  end

  controller do
    include ActiveAdmin::ControllerHelper

    def create
      @question_set = QuestionSet.new(question_set_params)
      if @question_set.save
        redirect_to edit_admin_question_set_path(resource), notice: 'Question set has been created.'
      else
        render :new
      end
    end

    def add_universal_questions
      question_set = QuestionSet.find(params[:id])
      tree_data = params[:tree_data]

      question_ids = extract_fancy_tree_selected_questions(tree_data)
      question_set.link_questions(question_ids)

      redirect_to edit_admin_question_set_path(question_set),
                  flash: { notice: 'Question(s) added successfully.' }
    end

    private

    def question_set_params
      permitted_params.require(:question_set).permit(:title)
    end

  end
end
