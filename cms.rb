require "sinatra"
require "sinatra/reloader"

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
