class Admin::SystemEmailsController < Admin::EmailsController
  include SystemEmail::Identifiers

  protected

  def prepare_email_args
    args    = super.dup
    options = args.extract_options!

    case resource.identifier
    when FRIEND_EMAIL
      options.merge! :sender  => current_user, 
                     :page    => UserPage.first, 
                     :message => 'test message'

    when RESET_PASSWORD
      # 

    when NEW_CONTENT_ALERT
      page = UserPage.first
      options.merge! :page   => page,
                     :sender => page.try(:author)

    when COMMENT_UPDATE
      comment = Comment.first
      options.merge! :page   => comment,
                     :sender => comment.try(:author)
    end

    (args << options)
  end

  def interpolation_options
    { :target => current_user.email }
  end

  def default_ordered_on
    'name'
  end

  def default_ordered_dir
    'ASC'
  end
end
