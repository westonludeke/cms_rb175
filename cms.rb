require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"
require "yaml"
require "bcrypt"

configure do 
  enable :sessions
  set :session_secret, 'super secret'
end

helpers do
  def data_path
    if ENV["RACK_ENV"] == "test"
      File.expand_path("../test/data", __FILE__)
    else
      File.expand_path("../data", __FILE__)
    end
  end

  def render_markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(text)
  end

  def user_list
    if ENV["RACK_ENV"] == "test"
      YAML.load(File.read("../test/users.yml"))
    else 
      YAML.load(File.read("users.yml"))
    end
  end

  def load_files_contents(file)
    if File.extname(file) == ".md"
      erb render_markdown(File.read(file))
    else
      headers["Content-Type"] = "text/plain"
      File.read(file)
    end 
  end

  def valid_credentials?(username, password)
    if user_list.key?(username)
      bcrypt_password = BCrypt::Password.new(user_list[username])
      bcrypt_password == password
    else 
      false
    end
  end

  def is_user_signed_in?
    session[:username] != nil
  end

  def not_logged_in_redirect
    if is_user_signed_in? == false
      session[:message] = "Sorry, you must be logged in to do that!"
      redirect "/"
    end
  end
end

# Home page
get "/" do 
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map { |path| File.basename(path) }

  erb :index
end

# Render login page
get "/users/login" do
  erb :login
end

# Check login credentials and either login or redirect
post "/users/login" do
  if valid_credentials?(params[:username], params[:password])
    session[:username] = params[:username]
    session[:message] = "Welcome!"
    redirect "/"
  else
    session[:message] = "Invalid user credentials"
    status 422
    erb :login
  end
end

# log out
post "/users/logout" do
  session.delete(:username)
  session[:message] = "You are now logged out!"
  redirect "/"
end

# Render new file creation page
get "/new" do
  not_logged_in_redirect
  erb :new
end

# Add new file
post "/create" do 
  new_file_name = params[:new_file_name].to_s

  not_logged_in_redirect

  if new_file_name.size == 0
    session[:message] = "The file name cannot be blank"
    status 422
    erb :new
  elsif File.extname(new_file_name) == ""
    session[:message] = "The file name must include an extension"
    status 422
    erb :new
  else
    file_path = File.join(data_path, new_file_name)

    File.write(file_path, "")
    session[:message] = "#{new_file_name} has been created!"
    
    redirect "/"
  end
end

# Render specific file page
get "/:file_name" do
  file_path = File.join(data_path, params[:file_name])

  if File.file?(file_path)
    load_files_contents(file_path)
  else
    session[:message] = "#{params[:file_name]} does not exist"
    redirect "/"
  end
end

# Render file edit form
get "/:file_name/edit" do
  file_path = File.join(data_path, params[:file_name])
  
  not_logged_in_redirect

  @requested_file = params[:file_name]
  @content = File.read(file_path)

  erb :edit
end

# Edit existing file's contents
post "/:file_name/edit" do
  file_path = File.join(data_path, params[:file_name])

  not_logged_in_redirect

  File.write(file_path, params[:content])

  session[:message] = "#{params[:file_name]} has been edited"
  redirect "/"
end

# Delete a specific file
post "/:file_name/delete" do 
  file_path = File.join(data_path, params[:file_name])

  not_logged_in_redirect

  File.delete(file_path)

  session[:message] = "#{params[:file_name]} has been deleted"
  redirect "/"
end





