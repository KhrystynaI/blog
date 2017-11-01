ActiveAdmin.register DocumentLink do
  menu false
  permit_params :document_set_id, :document_id

  controller do

    def create
      @document_link = DocumentLink.new(dl_params)
      respond_to do |format|
        if @document_link.save && @document_link.document_set.save
          format.html { redirect_to edit_polymorphic_path([:admin, @document_link.document_set], anchor: 'documents'),
                                    notice: 'Document has been added.' }
        else
          format.html { redirect_to edit_polymorphic_path([:admin, @document_link.document_set], anchor: 'documents') }
        end
      end
    end

    def destroy
      resource.destroy!
      resource.document_set.save!
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path([:admin, resource.document_set], anchor: 'documents'),
                                  notice: 'Document has been deleted.' }
      end
    end

    private

    def dl_params
      params.require(:document_link).permit(:document_id, :document_set_id)
    end

  end
end
