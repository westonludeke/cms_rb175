require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

get "/" do
  @files = Dir.glob(root + "/data/*").map { |path| File.basename(path) }
  @files.sort!
  erb :index
end

get "/about.txt" do 
  @contents = File.read("data/about.txt")
  erb :page
end

get "/changes.txt" do 
  @contents = File.read("data/changes.txt")
  erb :page
end

get "/history.txt" do 
  @contents = File.read("data/history.txt")
  erb :page
end
