ActiveAdmin.register FileLink do
  menu false
  permit_params :file

  controller do

    def update
      respond_to do |format|
        if resource.update(ql_params)
          format.html { redirect_to edit_polymorphic_path([:admin, resource.subject], anchor: 'files'),
                                    notice: 'File has been updated.' }
        else
          format.html { redirect_to edit_polymorphic_path([:admin, resource.subject], anchor: 'files') }
        end
      end
    end

    def destroy
      resource.destroy
      respond_to do |format|
        format.html { redirect_to edit_polymorphic_path([:admin, resource.subject], anchor: 'files'),
                                  notice: 'File has been destroyed.' }
      end
    end

    private
    def ql_params
      params.require(:file_link).permit(:file)
    end
  end
end
