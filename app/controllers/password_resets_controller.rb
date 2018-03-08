class PasswordResetsController < ApplicationController
  before_action :load_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "password_resets.create.messages"
      redirect_to root_url
    else
      flash.now[:danger] = t "password_resets.create.not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("password_resets.update.error")
      render :edit
    elsif @user.update_attributes user_params
      update_success
    else
      render :edit
    end
  end

  private

  def user_params
    params.require :user.permit :password, :password_confirmation
  end

  def load_user
    @user = User.find_by email: params[:email]
    @user || render(file: "public/404.html", status: 404, layout: true)
  end

  # Confirms a valid user.
  def valid_user
    unless @user && @user.activated? &&
           @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = t "password_resets.check_expiration.expired"
      redirect_to new_password_reset_url
    end
  end

  def update_success
    log_in @user
    @user.update_attribute :reset_digest, nil
    flash[:success] = t "password_resets.update.success"
    redirect_to @user
  end
end
