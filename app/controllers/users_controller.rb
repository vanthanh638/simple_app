# User controller
class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy)
  before_action :logged_in_user, only: %i(index edit update)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "users.new.info"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  # update user
  def update
    if @user.update_attributes user_params
      flash[:success] = t "users.edit.update"
      redirect_to @user
    else
      render :edit
    end
  end

  # Delete user
  def destroy
    @user.destroy
    flash[:success] = t "users.index.delete_success"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  # load user
  def load_user
    # find user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "users.new.user_nil"
    redirect_to signup_path
  end
end
