class AlertMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.alert_mailer.send_mail.subject
  #
  def send_mail(tenant_id,last_update,subject,body)
    tenant = Tenant.find tenant_id
  	#last_update = MachineLog.where(machine_id:data.machines.ids).order(:id).last.created_at.in_time_zone("Chennai").strftime("%I:%M %p")
  	@body = body
    mail from: "sales@yantra24x7.com"
    mail to: "prabhu.kittusamy@altiussolution.com,manisankar.gnanasekaran@adcltech.com,saravanan.senniyappan@adcltech.com,sarath.selvaraj@adcltech.com,rani.loganathan@adcltech.com"
    mail cc: "glidertechautomation@yahoo.com" if tenant_id == 18
    mail cc: "sureshgears@gmail.com" if tenant_id == 136
    mail cc: "info@ematindia.com" if tenant_id == 212
   
    mail subject: subject
  end

  def hour_report_mail_send(path)
    @path = path
    attachments[@path] = File.read(@path)
    mail from: "sales@yantra24x7.com"
    mail to:  "manisankar.gnanasekaran@adcltech.com"
    mail cc:  "sarath.selvaraj@adcltech.com, prabhu.kittusamy@altiussolution.com"
    mail subject:  "yantra24x7 Report"
  end




end
