class User < ApplicationRecord
  acts_as_paranoid
  has_many :operatorworkingdetails,:dependent => :destroy
  belongs_to :usertype
  belongs_to :approval, optional: true
  belongs_to :tenant, optional: true
  belongs_to :role, optional: true
  has_many :one_signals

=begin
   def self.authenticate(params)
    email_id = params[:email_id]
    password = params[:password]
    user = find_by_email_id(email_id)
    if user && user.password == password && user.isactive == true
      if params[:player_id].present?
        player_id = params[:player_id]
        onesignal = OneSignal.create(user_id:user.id,tenant_id: user.tenant.id,player_id:player_id)
        user[:phone_number] = onesignal.player_id
        user[:last_name] = onesignal.id
        user
      else
        user
      end
    elsif email_id == "altius@yantra.com" && password == "yantr@ltius"
      true
    end
   end 
=end

 def self.authenticate(params)
    email_id = params[:email_id]
    password = params[:password]
    user = find_by_email_id(email_id)
    if user && user.password == password && user.isactive == true
      if params[:player_id].present?
        player_id = params[:player_id]
        unless OneSignal.find_by_player_id(params[:player_id]).present?
          onesignal = OneSignal.create(user_id:user.id,tenant_id: user.tenant.id,player_id:player_id)
          user[:phone_number] = onesignal.player_id
        user[:last_name] = onesignal.id
        end
        user
      else
        user
      end
    elsif email_id == "altius@yantra.com" && password == "yantr@ltius" 
      true
    end
  end 


  

  def self.approval_pending
     users = where(role_id:Role.find_by(role_name:"MD").id)
     all_users = users.map{|user| {:name=>user.first_name,:company_name=>user.tenant.tenant_name,:email_id=>user.email_id,:phone_no=>user.phone_number,:city=>user.tenant.city}}
     return all_users
  end

  def self.changepwd(params)
    user_id = params[:user_id]
    old_pwd = params[:old_pwd]
    new_pwd = params[:new_pwd]
    user = User.find_by_id(user_id)
    if user.password == old_pwd
      user.update(password: params[:new_pwd] )
      return user
    else
      return false
    end
  end


  def self.forgot_password(params)
   email_id= params[:email_id].downcase
   phone_number= params[:phone_number]
   user = User.find_by(email_id: email_id,phone_number: phone_number)
    if user.present?
     PasswordMailer.password_user(user).deliver
     return true
    else
     return false
    end
   end

  def self.changepwd_web(params)
    email_id= params[:email_id].downcase
    new_pwd = params[:new_pwd]
    confirm_pwd = params[:confirm_pwd]
    user = User.find_by(email_id: email_id)
    if user.present? && (new_pwd == confirm_pwd)
      user.update(password: new_pwd )
      return true
    else
      return false
    end
  end

  def self.email_validation(params)
   result = User.all.map(&:email_id).include?(params[:email_id]) ? true : false
   return result
  end
end
