require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

get "/" do
  @files = Dir.glob(root + "/data/*").map { |path| File.basename(path) }
  @files.sort!
  erb :index
end

get "/:id" do 
  id = params[:id]
  @contents = File.read("data/#{id}.txt")

  erb :page
end
