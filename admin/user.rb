ActiveAdmin.register User do
  menu label: 'User List', parent: 'System'
  actions :all, except: [:show]
  permit_params :email, :password, :password_confirmation,
                :brid, :first_name, :last_name, :role, :address

  scope 'Employees', :employees, default: true

  index do
    selectable_column
    column :role
    column :first_name
    column :last_name
    column :email
    column :sign_in_count
    column :created_at
    actions if current_user.admin?
  end

  filter :email
  filter :first_name
  filter :last_name
  filter :role, as: :select, collection: proc { UserRole.collection.invert }
  filter :address

  form do |f|
    f.inputs 'User Details' do
      f.input :first_name
      f.input :last_name
      f.input :email
      if current_user.admin? || current_user.id.to_s == params[:id]
        f.input :password, input_html: {autocomplete: "off"}, required: false
        f.input :password_confirmation, required: false
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
    def update
      user = resource
      unless current_user.admin?
        params[:user].delete(:role)
      end

      if params[:user][:password].blank? || params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      if current_user.id.to_s == params[:id] || current_user.admin?
        return super
      end

      flash[:error] = 'You are not permitted to perform this action.'
      redirect_to :back
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
