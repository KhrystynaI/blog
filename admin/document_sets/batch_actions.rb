module Admin
  module DocumentSets
    module BatchActions

      class << self

        def included(base)
          base.batch_action :destroy, false

          define_batch_archive(base)
          define_batch_delete(base)
          define_batch_delete_subscribers(base)
          define_batch_delete_questions(base)
        end

        private

        def define_batch_archive(base)
          base.instance_eval do
            batch_action :archive, if: proc{ @current_scope.scope_method != :archived } do
              docsets = DocumentSet.where(id: params[:collection_selection])
              docsets.each do |docset|
                docset.archive!
              end
              redirect_to :back, info: "#{docsets.count} Document Set(s) have been archived."
            end
          end
        end

        def define_batch_delete(base)
          base.instance_eval do
            batch_action :delete, confirm: "Are you sure?", if: proc{ @current_scope.scope_method == :archived } do
              count = DocumentSet.destroy(params[:collection_selection])
              redirect_to :back, info: "#{count} Document Set(s) have been deleted."
            end
          end
        end

        def define_batch_delete_subscribers(base)
          base.instance_eval do
            member_action :delete_subscribers, method: :post
            controller do
              def delete_subscribers
                docset = DocumentSet.find_by(id: params.fetch(:id))
                order_items = docset.order_items.where(id: params.fetch(:ids))
                order_items.destroy_all
                render json: {message: 'The subscribers have been deleted from the Document Set.'}
              end
            end
          end

        end

        def define_batch_delete_questions(base)
          base.instance_eval do
            member_action :delete_questions, method: :post
            controller do
              def delete_questions
                docset = DocumentSet.find_by(id: params[:id])
                links = docset.question_links.where(id: params.fetch(:ids))
                links.destroy_all
                render json: {message: 'The questions have been deleted from the Document Set.'}
              end
            end
          end
        end
      end
    end
  end
end
