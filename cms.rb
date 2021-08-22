require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"

# enable ability to have sessions
configure do 
  enable :sessions
  set :session_secret, 'super secret'
end

root = File.expand_path("..", __FILE__)

get "/" do 
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:file_name" do
  file_path = root + "/data/" + params[:file_name]

  if File.file?(file_path)
    headers["Content-Type"] = "text/plain"
    File.read(file_path)
  else
    session[:message] = "#{params[:file_name]} does not exist."
    redirect "/"
  end
end
