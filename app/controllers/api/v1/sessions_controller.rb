module Api
  module V1
class SessionsController < ApplicationController
  before_action :set_session, only: [:show, :update, :destroy]

  # GET /sessions
  def index
    @sessions = Session.all
 
    render json: @sessions
  end

  # GET /sessions/1
  def show
    render json: @session
  end

  # POST /sessions
  def create      
    user = User.authenticate(params)
    if user  && user != true
      render json: {"id":user.id,"first_name":user.first_name,"usertype_id":user.usertype_id,"tenant_id":user.tenant_id,"role_id":user.role_id,"player_id":user.phone_number,"onesignal_id":user.last_name}
    elsif user == true
      render json: {"first_name":"Altius","usertype_id":"2"}
    else
      render json: false
    end

  end

  # PATCH/PUT /sessions/1
  def update
    if @session.update(session_params)
      render json: @session
    else
      render json: @session.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sessions/1
  def destroy
    @session.destroy
    #@session.update(isactive:0)
  end

  def forgot_pwd
  user = User.forgot_password(params)
  if user
      render json: user
    else
      render json: false
    end
  end

  def change_pwd_web
    user = User.changepwd_web(params)
    if user
      render json: user
    else
      render json: false
    end
  end

  def change_pwd
    user = User.changepwd(params)
    if user
      render json: user
    else
      render json: false
    end
  end
   
   def api
    return true
   end
    def alarm
    return true
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def session_params
      params.fetch(:session, {})
    end
end
end
end
