require 'nokogiri'
require 'open-uri'
p "enter start"
start = gets.chomp

p "enter destination"
finish = gets.chomp
# uri = URI('http://en.wikipedia.org/wiki/Aerospace')
# starting_point_wiki = '/wiki/Muse'
starting_point_wiki = "/wiki/#{start}"
destination_wiki = "/wiki/#{finish}"
# destination = '/wiki/National_Basketball_Association'
# destination_wiki = '/wiki/Space_Shuttle'

destination = destination_wiki[6..-1]
## degree 1
starting_page = Nokogiri::HTML(open("http://en.wikipedia.org#{starting_point_wiki}"))

all_links_on_page = []
starting_page.search('a').each do |link|
  all_links_on_page << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
  if link['href'] == destination_wiki
    p link['href']
    puts "#{starting_point_wiki} -> #{destination_wiki}"
    break
  end
end

links_in_table=[]
starting_page.css('table a').each do |link|
  links_in_table << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
end

all_links_on_page.each_with_index do |wanted_link, wanted_link_index|
  links_in_table.each_with_index do |not_wanted_link, not_wanted_link_index|
    if wanted_link == not_wanted_link
      all_links_on_page.delete_at(wanted_link_index)
      links_in_table.delete_at(not_wanted_link_index)
    end
  end
end

as1 = all_links_on_page
as1.delete("/wiki/Main_Page")


## degree 2

destination_backlinks_page = Nokogiri::HTML(open("http://en.wikipedia.org/w/index.php?title=Special:WhatLinksHere/#{destination}&limit=500"))


nba1 = []
destination_backlinks_page.search('a').map do |link|
  nba1 << link['href'] if link['href'] =~ /^\/wiki[^:]*$/

end


missing_links = (as1 & nba1)
# missing_links.delete("/wiki/Main_Page")
missing_links.each do |link|
  puts "#{starting_point_wiki} -> #{link} -> #{destination_wiki}"
end


## degree 3



all_links_on_page.each do |page|
  starting_page = Nokogiri::HTML(open("http://en.wikipedia.org#{page}"))
  all_links_on_page = []
  starting_page.search('a').each do |link|
    all_links_on_page << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
  end

  links_in_table=[]
    starting_page.css('table a').each do |link|
    links_in_table << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
  end

  all_links_on_page.each_with_index do |wanted_link, wanted_link_index|
    links_in_table.each_with_index do |not_wanted_link, not_wanted_link_index|
      if wanted_link == not_wanted_link
        all_links_on_page.delete_at(wanted_link_index)
        links_in_table.delete_at(not_wanted_link_index)
      end
    end
  end

  as2 = all_links_on_page
  as2.delete("/wiki/Main_Page")

  missing_links = (as2 & nba1)

  missing_links.each do |link|
    puts "#{starting_point_wiki} -> #{page} -> #{link} -> #{destination_wiki}"
  end

end






# as1.each do |link|
#   link_page = Nokogiri::HTML(open('http://en.wikipedia.org#{link})')

# end


# puts nba1.uniq

# puts arr.uniq
# arr.delete("/wiki/Main_Page")
# link_pages = arr.uniq
# p link_pages.length


# second_round = []
# link_pages.each do |page|
#   # puts page
#   backlink_array = []
#   # if page == "/wiki/Aerospace"
#   second = Nokogiri::HTML(open('http://en.wikipedia.org'+page))
#   second.search('a').map do |link|
#     # second_round << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
#     p page if link['href'] == '/wiki/Aerospace'
#   end
# end

# second_round.delete("/wiki/Main_Page")
# second_link_pages = second_round.uniq
# p second_link_pages[0..300]
