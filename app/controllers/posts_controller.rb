class PostsController < ApplicationController
  # before_action :authenticate_user
  before_action :ensure_correct_user, {only: [:edit, :update, :destroy]}
  
  def index
    @posts = Post.all.order(created_at: :desc)

    if @posts[0]
      @hash = Gmaps4rails.build_markers(@posts) do |post, marker|
        marker.lat post.latitude
        marker.lng post.longitude
        marker.infowindow post.name
      end
    else
      flash[:notie] = "投稿がありません"
      redirect_to("/posts/new")
    end
  end
  
  def show
  
    @post = Post.find_by(id: params[:id])
    @user = @post.user
    @likes_count = Like.where(post_id: @post.id).count
    
    @hash = Gmaps4rails.build_markers(@post) do |post, marker|
      marker.lat post.latitude
      marker.lng post.longitude
      marker.infowindow post.name
    end

    
  end
  
  def new
    @post = Post.new
  end
  
  def create

    #検索
    places = Geocoder.search(params[:name])
    
    if places[0]
      latitude = places[0].geometry['location']['lat']
      longitude = places[0].geometry['location']['lng']

      @hash = Gmaps4rails.build_markers(places) do |places, marker|
        marker.lat places.latitude
        marker.lng places.longitude
        marker.infowindow params[:name]
      end
      flash[:notice] = "住所が見つかりました！"
    else
      flash[:notice] = "住所が見つかりませんでした。もう一度検索してください。"
    end
    
    @post = Post.new(
      content: params[:content],
      user_id: @current_user.id,
      name: params[:name],
      latitude: latitude,
      longitude: longitude
    )
    
    
# binding.pry
    #「検索」ボタンの場合は登録しない
    if params[:search]
      render("/posts/new", post: @post)
    else
    #「投稿」ボタンの場合は画像と投稿を保存
      # 画像を保存
      if params[:image]
        @post.image_name = "#{@post.latitude + @post.longitude}.jpg"
        image = params[:image]
        File.binwrite("public/post_images/#{@post.image_name}", image.read)
      end
        
      if @post.save
        
        
        flash[:notice] = "投稿を作成しました"
        redirect_to("/posts/index")
      else
        render("posts/new")
      end
      
    end
    
  end
  
  def edit
    @post = Post.find_by(id: params[:id])
  end
  
  def update
    @post = Post.find_by(id: params[:id])
    @post.content = params[:content]
    if @post.save
      flash[:notice] = "投稿を編集しました"
      redirect_to("/posts/index")
    else
      render("posts/edit")
    end
  end
  
  def destroy
    @post = Post.find_by(id: params[:id])
    @post.destroy
    flash[:notice] = "投稿を削除しました"
    redirect_to("/posts/index")
  end
  
  def ensure_correct_user
    @post = Post.find_by(id: params[:id])
    if @post.user_id != @current_user.id
      flash[:notice] = "権限がありません"
      redirect_to("/posts/index")
    end
  end
  
end
