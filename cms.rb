require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"

# enable ability to have sessions
configure do 
  enable :sessions
  set :session_secret, 'super secret'
end

root = File.expand_path("..", __FILE__)

helpers do 
  def render_markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(text)
  end

  def load_files_contents(file)
    if File.extname(file) == ".md"
      render_markdown(File.read(file))
    else
      headers["Content-Type"] = "text/plain"
      File.read(file)
    end 
  end
end

get "/" do 
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:file_name" do
  file_path = root + "/data/" + params[:file_name]

  if File.file?(file_path)
    load_files_contents(file_path)
  else
    session[:message] = "#{params[:file_name]} does not exist."
    redirect "/"
  end
end


get "/:file_name/edit" do
  file_path = root + "/data/" + params[:file_name]
  
  @requested_file = params[:file_name]
  @content = File.read(file_path)

  erb :edit
end

post "/:file_name" do
  file_path = root + "/data/" + params[:file_name]

  File.write(file_path, params[:content])

  session[:message] = "#{params[:file_name]} has been edited"
  redirect "/"
end


