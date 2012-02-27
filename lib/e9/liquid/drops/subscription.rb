class E9::Liquid::Drops::Subscription < E9::Liquid::Drops::Base
  source_methods :first_name, :last_name, :username, :email

  def unsubscribe_url
    controller_send(:subscription_url, @object)
  end

  def unsubscribe_path
    controller_send(:subscription_path, @object)
  end
end
