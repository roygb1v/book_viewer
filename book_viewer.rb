require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split(/\n\n/).map {|sentence| "<p>#{sentence}</p>"}.join('')
  end

  def no_matches
    "Sorry, no matches were found."
  end
end

get "/search" do
  @hsh = {}
  @arr = []
  @regex_arr = []
  @list_of_toc = []
  @searching = params[:query].scan(/\w+/).join(' ')
  @toc = File.readlines("data/toc.txt")  
  files = Dir.glob("data/chp*.txt")
  files.each do |file|
    @arr << file if !File.read(file).downcase.scan(@searching).empty?
  end

  @toc.each_with_index do |chapter, index|
    @hsh[(index + 1).to_s] = chapter 
  end

  files.each do |file|
    @regex_arr << File.read(file).scan(/.*#{@searching}.{1,}/i)
  end

  @regex_arr = @regex_arr.reject {|arr| arr.empty?}

  num_arr = @arr.map {|n| n.scan(/\d+/)}.flatten
  num_arr.each {|num| @list_of_toc << @hsh[num]}
  @real_zip = num_arr.zip(@list_of_toc).zip(@regex_arr)
  erb(:search)
end
    
not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb(:home)
end

get "/chapters/:number" do 
  num = params[:number].to_i

  redirect "/" unless (1..@contents.size).cover?(num)

  @chapter = File.read("data/chp#{num}.txt")
  @toc = File.readlines("data/toc.txt")
  real_title = @toc[num - 1]
  @title = "Chapter #{num}: #{real_title}"
  erb(:chapter)
end

get "/show/:name" do
  params[:name]
end
