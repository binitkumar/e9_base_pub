class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.to = "travis@e9digital.com"
    #message.to = "numbers1311407@gmail.com"

    # returing false will stop the mail from sending
    #return false
    return true
  end
end
