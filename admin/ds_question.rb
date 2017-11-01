ActiveAdmin.register DsQuestion do
  menu false
  permit_params :document_set_id, :question_link_id, :answer

  member_action :restore_answer do
    resource.answer = nil
    resource.save!
    respond_to do |format|
      format.html { redirect_to edit_polymorphic_path([:admin, resource.document_set], anchor: 'questions'),
                                notice: 'Answer has been restored.' }
    end
  end

  controller do

    def update
      respond_to do |format|
        if resource.update(ql_params)
          format.html { redirect_to edit_polymorphic_path([:admin, resource.document_set], anchor: 'questions'),
                                    notice: 'Question has been updated.' }
        else
          format.html { redirect_to edit_polymorphic_path([:admin, resource.document_set], anchor: 'questions') }
        end
      end
    end

    def destroy
      resource.destroy
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path([:admin, resource.document_set], anchor: 'questions'),
                                  notice: 'Question has been deleted.' }
      end
    end

    private
    def ql_params
      params.require(:ds_question).permit(:document_set_id, :question_link_id, :answer)
    end
  end
end
