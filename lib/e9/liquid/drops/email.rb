class E9::Liquid::Drops::Email < E9::Liquid::Drops::Base
  source_methods :to_email, :from_email, :reply_email, :message

  alias :recipient :to_email
  alias :to :to_email
  alias :sender :from_email
  alias :from :from_email
  alias :reply_to :reply_email
end
