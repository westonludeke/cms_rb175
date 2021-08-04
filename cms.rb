require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

helpers do 
  def get_list_of_files
    @files = Dir.entries('data')
    @files
  end
end

get "/" do 
  redirect "/files"
end

get "/files" do 
  erb :files
end
