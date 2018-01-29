get '/comments' do
  if admin?
    @all_comments = Comment.all.order(created_at: :desc)
    erb :'comments/index'
  end
end

get '/posts/:id/comments/new' do
  @post = Post.find_by(id: params[:id])
  @comment = Comment.new
  erb :'comments/new'
end

post '/posts/:id/comments' do
  authenticate!
  @comment = Comment.new(content: params[:comment], post_id: params[:id], author_id: current_user.id)
  if @comment.save
    redirect "/posts/#{params[:id]}"
  else
    status 422
    @post = Post.find_by(id: params[:id])
    @errors = @comment.errors.full_messages
    erb :'comments/new'
  end
end

get '/posts/:id/comments/:comment_id/edit' do
  @post = Post.find_by(id: params[:id])
  @comment = Comment.find_by(id: params[:comment_id])
  if author?(@comment.author_id)
    erb :'comments/edit'
  else
    redirect "/posts/#{params[:id]}"
  end
end

put '/posts/:id/comments/:comment_id' do
  @post = Post.find_by(id: params[:id])
  @comment = Comment.find_by(id: params[:comment_id])
  if author?(@comment.author_id)
    @comment.update_attributes(content: params[:comment])
    if @comment.save
      redirect "/posts/#{params[:id]}"
    else
      status 422
      @errors = @comment.errors.full_messages
      erb :'comments/edit'
    end
  else
    @errors = ["It's not your comment!"]
    redirect "/posts/#{params[:id]}"
  end
end

delete '/posts/:id/comments/:comment_id' do
  @comment = Comment.find_by(id: params[:comment_id])
  if author?(@comment.author_id) || admin?
    @comment.destroy
    redirect back if admin?
    # delete likes???
    redirect "/posts/#{params[:id]}"
  else
    @errors = ["It's not your comment!"]
    redirect "/posts/#{params[:id]}"
  end
end
