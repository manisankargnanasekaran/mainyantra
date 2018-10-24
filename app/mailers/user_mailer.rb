class UserMailer < ApplicationMailer
def sample_email(user)
    mail from: "sales@yantra24x7.com"
    mail to: "manoj.rajendran@altiussolution.com,prabhu.kittusamy@altiussolution.com",:subject => 'Waiting For Apporval'
  end
end
