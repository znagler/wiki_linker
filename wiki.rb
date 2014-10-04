require 'nokogiri'
require 'open-uri'

class WikiSolver

  def initialize
    @user_input_start = ""
    @user_input_destination = ""
    @starting_wiki_route = get_starting_page
    @destination_wiki_route = get_destination_page
    @valid_starting_wiki_route = false
    @valid_destination_wiki_route = false
    @page = nil
    @routes_on_starting_wiki = []
  end

  def run!
    View.final_inputs(get_full_wiki_url(@starting_wiki_route), get_full_wiki_url(@destination_wiki_route))
    degree_one
    degree_two
    degree_three
  end

  def get_starting_page
    until @valid_starting_wiki_route == true
      View.starting_page
      @user_input_start = View.get_user_input
      validate("/wiki/#{@user_input_start}",:start)
    end
    "/wiki/#{@user_input_start}"
  end

  def get_destination_page
    until @valid_destination_wiki_route == true
      View.destination_page
      @user_input_destination = View.get_user_input
      validate("/wiki/#{@user_input_destination}",:destination)
    end
    "/wiki/#{@user_input_destination}"
  end

  def get_full_wiki_url(wiki_url_route)
    "http://en.wikipedia.org#{wiki_url_route}"
  end

  def validate(wiki_url_route, start_or_destination)
    begin
      Nokogiri::HTML(open("http://en.wikipedia.org#{wiki_url_route}"))
    rescue OpenURI::HTTPError => e
      puts "Invalid Page!"
    else
      @valid_starting_wiki_route = true if start_or_destination == :start
      @valid_destination_wiki_route = true if start_or_destination == :destination
    end
  end

######### Helper Methods ############

  def get_wiki_routes(page)
    all_routes_on_page = []
    page.search('a').each do |link|
      all_routes_on_page << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
    end


    routes_in_table=[]
    page.css('table a').each do |link|
      routes_in_table << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
    end

    all_routes_on_page.each_with_index do |wanted_link, wanted_link_index|
      routes_in_table.each_with_index do |not_wanted_link, not_wanted_link_index|
        if wanted_link == not_wanted_link
          all_routes_on_page.delete_at(wanted_link_index)
          routes_in_table.delete_at(not_wanted_link_index)
        end
      end
    end

    all_routes_on_page.delete("/wiki/Main_Page")
    all_routes_on_page.compact.uniq
  end

######### Degree One ############
  def degree_one
    page = Nokogiri::HTML(open("http://en.wikipedia.org#{@starting_wiki_route}"))
    @routes_on_starting_wiki = get_wiki_routes(page)
    @routes_on_starting_wiki.each do |route|
     if route.downcase == @destination_wiki_route.downcase
        View.first_degree_match(@starting_wiki_route, @destination_wiki_route)
        return
      end
    end

  end





######### Degree Two ############
  def degree_two
    backlinks_page = Nokogiri::HTML(open("http://en.wikipedia.org/w/index.php?title=Special:WhatLinksHere/#{@user_input_destination}&limit=10000"))
    @backlink_routes_from_destination_wiki = get_wiki_routes(backlinks_page)
    second_degree_matches = (@routes_on_starting_wiki & @backlink_routes_from_destination_wiki)
    View.second_degree_match(@starting_wiki_route, @destination_wiki_route, second_degree_matches)
  end







######### Degree Three ############
  def degree_three
    second_and_third_degree_links = []

    @routes_on_starting_wiki.each do |route|

      page = Nokogiri::HTML(open("http://en.wikipedia.org#{route}"))
      routes_on_current_page = get_wiki_routes(page)
      routes_on_current_page.each do |r|
        if @backlink_routes_from_destination_wiki.include?(r)
          second_and_third_degree_links << [route, r]
        end
      end

    end
    View.third_degree_match(@starting_wiki_route, @destination_wiki_route, second_and_third_degree_links)

  end




# all_links_on_page.each do |page|
#   starting_page = Nokogiri::HTML(open("http://en.wikipedia.org#{page}"))
#   all_links_on_page = []
#   starting_page.search('a').each do |link|
#     all_links_on_page << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
#   end

#   links_in_table=[]
#     starting_page.css('table a').each do |link|
#     links_in_table << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
#   end

#   all_links_on_page.each_with_index do |wanted_link, wanted_link_index|
#     links_in_table.each_with_index do |not_wanted_link, not_wanted_link_index|
#       if wanted_link == not_wanted_link
#         all_links_on_page.delete_at(wanted_link_index)
#         links_in_table.delete_at(not_wanted_link_index)
#       end
#     end
#   end

#   as2 = all_links_on_page
#   as2.delete("/wiki/Main_Page")

#   missing_links = (as2 & nba1)

#   missing_links.each do |link|
#     puts "#{starting_point_wiki} -> #{page} -> #{link} -> #{destination_wiki}"
#   end

# end







end












class View
  class << self
    def starting_page
      print "Enter Starting Wiki Page: "
    end

    def destination_page
      print "Enter Destination Wiki Page: "
    end

    def final_inputs(full_start_wiki_url, full_destination_wiki_url)
      puts "-"*30
      puts "Starting page: #{full_start_wiki_url}"
      puts "Destination page: #{full_destination_wiki_url}"
      puts "-"*30
    end

    def get_user_input
      gets.chomp
    end

    def first_degree_match(start_wiki_route, destination_wiki_route)
      puts "#{start_wiki_route} -> #{destination_wiki_route}"
    end

    def second_degree_match(start_wiki_route, destination_wiki_route, array_of_second_degree_matches)
      array_of_second_degree_matches.each do |route|
        puts "#{start_wiki_route} -> #{route} -> #{destination_wiki_route}"
      end
    end

    def third_degree_match(starting_wiki_route, destination_wiki_route, second_and_third_degree_links)
      second_and_third_degree_links.each do |pair|
        puts "#{starting_wiki_route} -> #{pair[0]} -> #{pair[1]} -> #{destination_wiki_route}"
      end
    end


  end
end

a = WikiSolver.new
a.run!










# destination = destination_wiki[6..-1]
# # starting_page = Nokogiri::HTML(open("http://en.wikipedia.org#{starting_point_wiki}"))

# begin
#   starting_page = Nokogiri::HTML(open("http://en.wikipedia.org#{starting_point_wiki}"))
# rescue OpenURI::HTTPError => e
#   if e.message == '404 Not Found'
#     puts "The Starting Wiki page you entered is not valid!"
#   else
#     raise e
#     get_starting_page
#   end
# end

# ##checking user input

# starting_page.search('b').each do |link|
#   p link.inner_HTML
# end



# ## degree 1

# all_links_on_page = []
# starting_page.search('a').each do |link|
#   all_links_on_page << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
#   if link['href'] == destination_wiki
#     p link['href']
#     puts "#{starting_point_wiki} -> #{destination_wiki}"
#     break
#   end
# end

# links_in_table=[]
# starting_page.css('table a').each do |link|
#   links_in_table << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
# end

# all_links_on_page.each_with_index do |wanted_link, wanted_link_index|
#   links_in_table.each_with_index do |not_wanted_link, not_wanted_link_index|
#     if wanted_link == not_wanted_link
#       all_links_on_page.delete_at(wanted_link_index)
#       links_in_table.delete_at(not_wanted_link_index)
#     end
#   end
# end

# as1 = all_links_on_page
# as1.delete("/wiki/Main_Page")


# ## degree 2

# destination_backlinks_page = Nokogiri::HTML(open("http://en.wikipedia.org/w/index.php?title=Special:WhatLinksHere/#{destination}&limit=500"))


# nba1 = []
# destination_backlinks_page.search('a').map do |link|
#   nba1 << link['href'] if link['href'] =~ /^\/wiki[^:]*$/

# end


# missing_links = (as1 & nba1)
# # missing_links.delete("/wiki/Main_Page")
# missing_links.each do |link|
#   puts "#{starting_point_wiki} -> #{link} -> #{destination_wiki}"
# end


# ## degree 3



# all_links_on_page.each do |page|
#   starting_page = Nokogiri::HTML(open("http://en.wikipedia.org#{page}"))
#   all_links_on_page = []
#   starting_page.search('a').each do |link|
#     all_links_on_page << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
#   end

#   links_in_table=[]
#     starting_page.css('table a').each do |link|
#     links_in_table << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
#   end

#   all_links_on_page.each_with_index do |wanted_link, wanted_link_index|
#     links_in_table.each_with_index do |not_wanted_link, not_wanted_link_index|
#       if wanted_link == not_wanted_link
#         all_links_on_page.delete_at(wanted_link_index)
#         links_in_table.delete_at(not_wanted_link_index)
#       end
#     end
#   end

#   as2 = all_links_on_page
#   as2.delete("/wiki/Main_Page")

#   missing_links = (as2 & nba1)

#   missing_links.each do |link|
#     puts "#{starting_point_wiki} -> #{page} -> #{link} -> #{destination_wiki}"
#   end

# end






# # as1.each do |link|
# #   link_page = Nokogiri::HTML(open('http://en.wikipedia.org#{link})')

# # end


# # puts nba1.uniq

# # puts arr.uniq
# # arr.delete("/wiki/Main_Page")
# # link_pages = arr.uniq
# # p link_pages.length


# # second_round = []
# # link_pages.each do |page|
# #   # puts page
# #   backlink_array = []
# #   # if page == "/wiki/Aerospace"
# #   second = Nokogiri::HTML(open('http://en.wikipedia.org'+page))
# #   second.search('a').map do |link|
# #     # second_round << link['href'] if link['href'] =~ /^\/wiki[^:]*$/
# #     p page if link['href'] == '/wiki/Aerospace'
# #   end
# # end

# # second_round.delete("/wiki/Main_Page")
# # second_link_pages = second_round.uniq
# # p second_link_pages[0..300]
