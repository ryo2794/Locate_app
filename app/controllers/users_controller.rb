class UsersController < ApplicationController
  # before_action :authenticate_user, {only: [:index, :show, :edit, :update]}
  before_action :forbid_login_user, {only: [:new, :create, :login_form, :login]}
  before_action :ensure_correct_user, {only: [:edit, :update]}
  
  def index
    @users = User.all
  end
  
  def show
    @user = User.find_by(id: params[:id])
    
    @hash = Gmaps4rails.build_markers(@user.posts) do |post, marker|
      marker.lat post.latitude
      marker.lng post.longitude
      marker.infowindow post.name
    end
    
  end
  
  def new
    @user = User.new
  end
  
  def create

    #検索
    places = Geocoder.search(params[:place])
    
    if places[0]
      latitude = places[0].geometry['location']['lat']
      longitude = places[0].geometry['location']['lng']

      @hash = Gmaps4rails.build_markers(places) do |places, marker|
        marker.lat places.latitude
        marker.lng places.longitude
        marker.infowindow params[:place]
      end
      flash[:notice] = "住所が見つかりました！"
    else
      flash[:notice] = "住所が見つかりませんでした。もう一度検索してください。"
    end

    @user = User.new(
      name: params[:name],
      email: params[:email],
      image_name: "default_user.jpg",
      password: params[:password],
      latitude: latitude,
      longitude: longitude
    )

#binding.pry

    @place = params[:place]
      
    #「検索」ボタンの場合は登録しない
    if params[:search]
      render("/users/new", user: @user)
    else
    #「登録」ボタンの場合はユーザーを保存
      if @user.save
        session[:user_id] = @user.id
        flash[:notice] = "ユーザー登録が完了しました"
        redirect_to("/users/#{@user.id}")
      else
        render("/users/new", user: @user)
      end
    end
  end
  
  def edit
    @user = User.find_by(id: params[:id])
  end
  
  def update
    @user = User.find_by(id: params[:id])
    @user.name = params[:name]
    @user.email = params[:email]
    
    if params[:image]
      @user.image_name = "#{@user.id}.jpg"
      image = params[:image]
      File.binwrite("public/user_images/#{@user.image_name}", image.read)
    end
    
    if @user.save
      flash[:notice] = "ユーザー情報を編集しました"
      redirect_to("/users/#{@user.id}")
    else
      render("users/edit")
    end
  end
  
  def login_form
  end
  
  def login
    # メールアドレスのみを用いて、ユーザーを取得するように書き換えてください
    @user = User.find_by(email: params[:email])
    # if文の条件を&&とauthenticateメソッドを用いて書き換えてください
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:notice] = "ログインしました"
      redirect_to("/posts/index")
    else
      @error_message = "メールアドレスまたはパスワードが間違っています"
      @email = params[:email]
      @password = params[:password]
      render("users/login_form")
    end
  end
  
  def logout
    session[:user_id] = nil
    flash[:notice] = "ログアウトしました"
    redirect_to("/login")
  end
  
  def likes
    @user = User.find_by(id: params[:id])
    @likes = Like.where(user_id: @user.id)
    
    @hash = Gmaps4rails.build_markers(@user.posts) do |post, marker|
      marker.lat post.latitude
      marker.lng post.longitude
      marker.infowindow post.name
    end
    
  end
  
  def ensure_correct_user
    if @current_user.id != params[:id].to_i
      flash[:notice] = "権限がありません"
      redirect_to("/posts/index")
    end
  end
  
end
