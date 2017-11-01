ActiveAdmin.register User, as: 'Subscriber' do

  menu label: 'Subscribers', parent: 'Data'
  actions :all, except: [:show]
  permit_params :email, :password, :password_confirmation,
                :brid, :first_name, :last_name, :role, :address

  index do
    selectable_column
    column 'Employee ID', :brid
    column :first_name
    column :last_name
    column :created_at
    column :customer
    actions if current_user.admin?
  end

  filter :brid, label: 'Employee ID'
  filter :first_name
  filter :last_name
  filter :address
  filter :customer

  form do |f|
    f.inputs 'User Details' do
      if f.object.role == 'subscriber' || f.object.new_record?
        f.input :customer
        f.input :brid, label: 'Employee ID'
      end
      f.input :first_name
      f.input :last_name
      f.input :email
      if current_user.admin? || current_user.id.to_s == params[:id]
        f.input :password, input_html: {autocomplete: "off"}
        f.input :password_confirmation
      end

      f.input :address

      if current_user.admin?
        f.input :role, as: :select,
                collection: UserRole.collection.invert
      end
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.subscribers
    end


    def update
      user = User.find_by!(id: params[:id])
      if params[:user][:role].to_s != user.role.to_s && !current_user.admin?
        flash[:error] = 'You are not permitted to update user.'
        return redirect_to '/admin/subscribers'
      end

      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if current_user.id.to_s == params[:id] || current_user.admin?
        return super
      end

      flash[:error] = 'You are not permitted to perform this action.'
      redirect_to '/admin/subscribers'
    end

    def destroy
      if current_user.id.to_s == params[:id] || current_user.admin?
        super
      else
        flash[:error] = 'You are not permitted to perform this action.'
        redirect_to :back
      end
    end
  end

end
