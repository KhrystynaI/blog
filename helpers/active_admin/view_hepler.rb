module ActiveAdmin
  module ViewHelper
    # def file(file_path)
    #   File.read(File.join(Rails.root, file_path))
    # end
    #
    # def groupify_document_set_questions(_questions)
    #   YAML.load(file('spec/fixtures/question_sections.yml')).map { |h| Hashie::Mash.new(h) }
    # end

    # This method create json structure for TreeTable javascript object. Example:
    # [{title: 'category name 1',
    # folder: true,
    # key: 'category id 1',
    # expend: true,
    # children: [
    #   {title: 'question name 1',
    #   key: 'question id 1'},
    #   {title: 'question name 2',
    #   key: 'question id 2'}]},
    # ...
    # ]
    def groupify_questions_for_tree(questions_array, group, need_answers, document = nil, customer = nil)
      main_array = []
      return main_array if questions_array.nil?

      if group == 'categories'
        add_categories(main_array, questions_array, questions_array, need_answers, document, customer) # empty_array, questions_to_add, questions_main_array
      else
        # add questions with sets
        QuestionSet.all.each do |set|
          new_set_h = {
            title: "<span class='question-set'>#{set.title}</span>",
            folder: true,
            key: "S#{set.id}",
            expanded: true,
            children: []
          }
          add_categories(new_set_h[:children], set.questions, questions_array, need_answers, document, customer) # empty_array, questions_to_add, questions_main_array
          main_array << new_set_h unless new_set_h[:children].count == 0 # check for empty arreys
        end
        # add questions without sets
        questions_in_sets = []
        QuestionSet.all.each { |set| set.questions.each { |question| questions_in_sets << question } }
        questions_without_sets = questions_array - questions_in_sets
        add_categories(main_array, questions_without_sets, questions_array, need_answers, document, customer) # empty_array, questions_to_add, questions_main_array
      end

      main_array
    end

    def add_categories(array, questions_array, questions_main_array, need_answers, document, customer)
      questions = questions_array.group_by(&:category)
      questions.each do |category|
        if category[0]
          new_h = {
            title: "<span class='question-category-title'>#{category[0].name}</span>",
            folder: true,
            key: "C#{category[0].id}",
            expanded: true,
            children: []
          }
          add_questions(new_h[:children], category[1], questions_main_array, need_answers, document, customer) # category_children_array, questions
          array << new_h unless new_h[:children].count == 0 # check for empty arreys
        else
          add_questions(array, category[1], questions_main_array, need_answers, document, customer) # questions without category
        end
      end
    end

    def add_questions(category_children_array, questions, questions_main_array, need_answers, document, customer)
      questions.each do |question|
        if need_answers
          question_link = QuestionLink.find_by(subject: document, :question => question)
          customer_mark = ''
          selected = false
          if customer && customer.questions.include?(question)
            customer_mark = '√'
            selected = true
          end
          answer_mark = ''
          if question_link && question_link.answer
            answer_mark = question_link.answer
          end
          category_children_array << {
            title: question.text,
            answer: answer_mark,
            customer_question: customer_mark,
            selected: selected,
            key: "Q#{question.id}"
          } if questions_main_array.include?(question) # check for include question
        else
          category_children_array << {
            title: question.text,
            key: "Q#{question.id}"
          } if questions_main_array.include?(question) # check for include question
        end
      end
    end

    def groupify_questions_for_list(questions)
      questions.includes(:category).order(
        'question_categories.position ASC, questions.position ASC').sort_by do |question|
        question.category&.position.to_i * 1000 + question.position.to_i
      end.group_by(&:category)
    end

    def generate_version_links(object_array)
      string = ""
      object_array.each do |version|
        string += "<a href='#{edit_polymorphic_path([:admin, version])}'>#{version.version}</a>, "
      end
      string.html_safe
    end

    def groupify_questions_for_ds_tree(questions_array, document_set)
      main_array = []
      return main_array if questions_array.nil?

      if document_set.documents.count > 0
        document_set.documents.each do |document|
          document_question_array = (document.questions - document_set.ds_questions_by_object(document))
          add_document_contract_questions(main_array, document_question_array, document, 'D', document_set.customer)
        end
      end
      if document_set.contract
        contract_questions_array = (document_set.contract.questions - document_set.ds_questions_by_object(document_set.contract))
        add_document_contract_questions(main_array, contract_questions_array, document_set.contract, 'T',
                                        document_set.customer)
      end
      add_general_questions(main_array, questions_array)
      main_array
    end

    def add_document_contract_questions(main_array, questions_array, document, letter, customer)
      new_doc_h = {
        title: "<span class='question-doc-title'>#{document.title}</span>",
        folder: true,
        key: "#{letter + document.id.to_s}",
        expanded: true,
        children: []
      }
      ids = []
      questions_array.each { |question| ids << question.id }
      document_questions_array = document.questions.where(id: ids).to_a
      new_doc_h[:children] = groupify_questions_for_tree(document_questions_array, 'sets', true, document, customer)
      main_array << new_doc_h unless new_doc_h[:children].count == 0
    end

    def add_general_questions(main_array, questions_array)
      new_general_h = {
        title: "<span class='question-doc-title'>General questions</span>",
        folder: true,
        key: "G",
        expanded: true,
        children: []
      }
      ids = []
      questions_array.each { |question| ids << question.id }
      general_questions_array = Question.standard.where(id: ids).to_a
      new_general_h[:children] = groupify_questions_for_tree(general_questions_array, 'categories', false)
      main_array << new_general_h unless new_general_h[:children].count == 0
    end

    def long_date_format(date)
      date&.strftime('%B %-d, %Y')
    end
  end
end
