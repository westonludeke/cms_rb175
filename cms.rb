require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

get "/" do
  @files = Dir.glob(root + "/data/*").map { |path| File.basename(path) }
  @files.sort!
  erb :index
end

get "/:page_id" do 
  content_type 'text/plain'
  @page_id = params[:page_id]

  # headers["Content-Type"] = "text/plain"
  @contents = File.read("data/#{@page_id}.txt")
  erb :page
end
