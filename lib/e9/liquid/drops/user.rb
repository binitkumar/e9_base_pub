class E9::Liquid::Drops::User < E9::Liquid::Drops::Linkable
  source_methods :first_name, :last_name, :username, :email, :email_to, :name, :roles, :role

  def admin?
    @object.role_includes?('administrator')
  end

  def reset_password_url
    controller_send(:edit_user_password_url, :reset_password_token => @object.reset_password_token)
  end

  def user_id
    @object.try(:id)
  end

  def reset_password_path
    controller_send(:edit_user_password_path, :reset_password_token => @object.reset_password_token)
  end

  def admin_url
    controller_send(:edit_admin_user_url, @object)
  end

  def admin_path
    controller_send(:edit_admin_user_path, @object)
  end
end
