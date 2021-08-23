require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

# enable ability to have sessions
configure do 
  enable :sessions
  set :session_secret, 'super secret'
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

helpers do
  def render_markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(text)
  end

  def load_files_contents(file)
    if File.extname(file) == ".md"
      erb render_markdown(File.read(file))
    else
      headers["Content-Type"] = "text/plain"
      File.read(file)
    end 
  end
end

# Home page
get "/" do 
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index
end

# Render new file creation page
get "/new" do 
  erb :new
end

# Add new file
post "/create" do 
  new_file_name = params[:new_file_name].to_s

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
    session[:message] = "The file #{new_file_name} has been created!"
    
    redirect "/"
  end
end

# Render specific file page
get "/:file_name" do
  file_path = File.join(data_path, params[:file_name])

  if File.file?(file_path)
    load_files_contents(file_path)
  else
    session[:message] = "#{params[:file_name]} does not exist."
    redirect "/"
  end
end

# Render file edit form
get "/:file_name/edit" do
  file_path = File.join(data_path, params[:file_name])
  
  @requested_file = params[:file_name]
  @content = File.read(file_path)

  erb :edit
end

# Edit existing file's contents
post "/:file_name/edit" do
  file_path = File.join(data_path, params[:file_name])

  File.write(file_path, params[:content])

  session[:message] = "#{params[:file_name]} has been edited"
  redirect "/"
end





