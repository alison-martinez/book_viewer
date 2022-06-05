require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text = "<p>" + text + "</p>"
    text.gsub!("\n\n", "</p><p>")
    text
  end
  
  def highlight(text, query)
    text.gsub!(query, "<strong>#{query}</strong>")
    text
  end

end
get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
  #File.read "public/template.html"
end

get "/chapters/:number" do

  num = params[:number].to_i
  chapter_name = @contents[num-1]
  @title = "Chapter #{num}: #{chapter_name}"
  
  filename = "data/chp" + params[:number] + ".txt"
  @chapter = File.read filename

  erb :chapter
end

not_found do
  redirect "/"
end

# Calls the block for each chapter, passing that chapter's number, name, and
# contents.
def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end


