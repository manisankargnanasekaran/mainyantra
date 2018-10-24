class PasswordMailer < ApplicationMailer
  def password_user(user)
    @user = user
    mail from: "sales@yantra24x7.com"
    mail to: @user.email_id, subject: 'Forgot Password mail from Yantra24x7'

  end
end
