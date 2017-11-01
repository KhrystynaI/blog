ActiveAdmin.register QuestionLink do
  menu false
  permit_params :question, :text, :category_id, :answer, :original_text

  controller do

    def update
      respond_to do |format|
        if resource.update(ql_params)
          format.html { redirect_to edit_polymorphic_path([:admin, resource.subject], anchor: 'questions'),
                                    notice: 'Question has been updated.' }
        else
          format.html { redirect_to edit_polymorphic_path([:admin, resource.subject], anchor: 'questions') }
        end
      end
    end

    def destroy
      resource.destroy
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path([:admin, resource.subject], anchor: 'questions'),
                                  notice: "Question has been removed from the #{resource.subject}." }
      end
    end

    private
    def ql_params
      params.require(:question_link).permit(:text, :category_id, :answer, :original_text)
    end
  end

  collection_action :update_answers, method: :post do
    QuestionLink.bulk_update(params[:updates])
    render json: {status: 'Ok'}
  end
end
