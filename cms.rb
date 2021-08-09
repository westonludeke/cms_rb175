require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

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

  def check_if_file_exists(file_path)
    if File.file?(file_path)
      load_file_content(file_path)
    else
      session[:message] = "#{params[:filename]} does not exist."
      redirect "/"
    end
  end

  def load_file_content(path)
    content = File.read(path)
    case File.extname(path)
    when ".txt"
      headers["Content-Type"] = "text/plain"
      content
    when ".md"
      render_markdown(content)
    end
  end
end

# view list of files
get "/" do
  @files = Dir.glob(root + "/data/*").map { |path| File.basename(path) }
  @files.sort!
  erb :index
end

# load file
get "/:filename" do 
  file_path = root + "/data/" + params[:filename]

  check_if_file_exists(file_path)
end

# edit file
get "/:filename/edit" do 
  file_path = root + "/data/" + params[:filename]

  check_if_file_exists(file_path)
end







