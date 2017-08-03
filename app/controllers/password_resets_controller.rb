class PasswordResetsController < ApplicationController
  before_action :find_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update) # Case (1)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "password_reset.new.instructions"
      redirect_to root_url
    else
      flash.now[:danger] = t "password_reset.new.not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?                  # Case (3)
      @user.errors.add :password, t "password_reset.empty"
      render :edit
    elsif @user.update_attributes(user_params)          # Case (4)
      log_in @user
      flash[:success] = t "password_reset.reset"
      redirect_to @user
    else
      render :edit # Case (2)
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Before filters

  def find_user
    @user = User.find_by email: params[:email]
    return if @user
    flash[:danger] = t "users.new.user_nil"
    redirect_to root_path
  end

  # Confirms a valid user.
  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "password_reset.expired"
    redirect_to new_password_reset_url
  end
end
