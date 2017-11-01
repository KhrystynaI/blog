module ActiveAdmin
  module ControllerHelper
    # Extracts selected question ids from a json constructed by FancyTree js.
    # @param tree_node [Hash] - a hash style tree extracted from controller params.
    #
    # Example:
    #     {"expanded":true,"key":"root_1","selected":false,"title":"root","children":[
    #       {"expanded":true,"folder":true,"key":"C2","selected":false,"title":"Derived Data creation","children":[
    #         {"key":"Q5","selected":false,"title":"Re-distribution externally"},
    #         {"key":"Q6","selected":false,"title":"Third Party data subject to underlying third party agreements"}]},
    #       {"expanded":true,"folder":true,"key":"C3","selected":true,"title":"Redistribution Permitted (if any)","children":[
    #         {"key":"Q8","selected":true,"title":"Tables"},
    #         {"key":"Q9","selected":true,"title":"Ad-hoc research re-distribution with attribution allowed"}]}]}
    def extract_fancy_tree_selected_questions(tree_node)
      question_ids = []
      return question_ids if tree_node.nil?

      if tree_node['key'].to_s.start_with?('Q') && tree_node['selected']
        question_ids << tree_node['key'][1..-1] # strip Q and extract question id.
      end

      if tree_node['children']
        tree_node['children'].each do |child|
          question_ids.concat extract_fancy_tree_selected_questions(child)
        end
      end

      question_ids
    end

    def extract_fancy_ds_tree_selected_questions(tree_node, question_object_id = nil, question_object_class_name = nil)
      question_ids = []
      return question_ids if tree_node.nil?

      if tree_node['key'].to_s.start_with?('D')
        question_object_id = tree_node['key'][1..-1]
        question_object_class_name = 'Document'
      end

      if tree_node['key'].to_s.start_with?('T')
        question_object_id = tree_node['key'][1..-1]
        question_object_class_name = 'Contract'
      end

      if tree_node['key'].to_s.start_with?('Q') && tree_node['selected']
        question_ids << {
            question_id: tree_node['key'][1..-1],
            question_object_id: question_object_id,
            question_object_class_name: question_object_class_name
        }
      end

      if tree_node['children']
        tree_node['children'].each do |child|
          question_ids.concat extract_fancy_ds_tree_selected_questions(child, question_object_id, question_object_class_name)
        end
      end

      question_ids
    end

    def backup_date(backup_path)
      backup_path.split('/').last
    end

    def editor_policy
      @editor_policy ||= ActiveAdmin::DocumentSetPolicy.new(current_user, resource)
    end
  end
end
