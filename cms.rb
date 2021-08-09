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
  @page_id = params[:page_id]

  redirect "/" unless File.exists?("data/#{@page_id}.txt")

  @contents = File.read("data/#{@page_id}.txt")
  erb :page
end
