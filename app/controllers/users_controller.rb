class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_correct_user, only: [:edit, :update, :show]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show

  def index
    @users = User.paginate(page: params[:page], per_page: 17). search(params[:search])
    @users = @users.where('name LIKE ?', "%#{params[:search]}%") if params[:search].present?
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
  def new
    if logged_in? && !current_user.admin?
      flash[:info] = 'すでにログインしてます。'
      redirect_to current_user
    else
      @user = User.new
    end
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報は更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  private #user_paramsメソッドは、Usersコントローラーの内部でのみ実行されます。
          #Web経由で外部のユーザーが知る必要は無いため、次に記すようにRubyのprivateキーワードを用いて
          #外部からは使用できないようにします
          
  def user_params #Strong Parameters
    params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
  end
  
  
  def basic_info_params
    params.require(:user).permit(:basic_time, :work_time)
  end
  
  def search
     #Viewのformで取得したパラメータをモデルに渡す
    @users = User.search(params[:search])
  end
  
   def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
   end
end