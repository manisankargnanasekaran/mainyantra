class ApprovalMailer < ApplicationMailer
  def approval_user(user)
    @user = user
    mail from: "sales@yantra24x7.com"
    mail to: @user.email_id, subject: 'Confirmation mail from Yantra24x7'
  end
end
