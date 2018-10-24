module Api
  module V1
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = Tenant.find(params[:tenant_id]).users.where.not(role_id:Tenant.find(params[:tenant_id]).roles.where(role_name:"CEO")[0].id)

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created#, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def pending_approvals
    all_users = User.approval_pending
    render json: all_users
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
       ApprovalMailer.approval_user(@user).deliver
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    render json: {message: 'User has been deleted'}
    #@user.update(isactive:0)
  end

  def email_validation
      result=User.email_validation(params)
      render json: result
  end

  def approval_list
    user = User.where(isactive: false)
     render json: user
   end
  
   def admin_user
    @users = User.where(usertype_id: 2)
    render json: @users
  end
  

  def password_recovery
    password = User.find_by(email_id:params[:email_id]).present? ? User.find_by(email_id:params[:email_id]).password : false
    
    password = {"password": password}
    render json: password
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email_id, :password, :phone_number, :remarks, :usertype_id, :approval_id, :tenant_id, :role_id,:isactive)
    end
end
end
end
