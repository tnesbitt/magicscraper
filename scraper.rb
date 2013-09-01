require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'open-uri'
require 'pry'

class Scraper

	def initialize 
		@doc = Nokogiri::HTML(open("http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=249736"))
	end
	
	def get_string_value(elementName)
		row = @doc.css("#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_#{elementName}").first
		string_value = nil
		if row && value = row.css('.value').first
			if content = value.content
				string_value = content.gsub(/(\r\n|\n)\s*/,"")
			end
		end
		string_value
	end
	
	def get_alt_value(elementName)
		row = @doc.css("#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_#{elementName}").first
		alt_value = []
		if row && value = row.css('.value').first
			value.children.each do | child |
				alt_value << child['alt'] if child.class==Nokogiri::XML::Element
			end
		end
		alt_value
	end
	
	def get_card_text()
		row = @doc.css("#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_textRow").first
		card_text = []
		if row && value = row.css('.value').first
			value.children.each do | child |
				text = ''
				child.children.each do | kid |
					if kid.class==Nokogiri::XML::Element
						text += kid['alt']
					elsif kid.class==Nokogiri::XML::Text
						text += kid.content.gsub(/(\r\n|\n)\s*/,"") if kid.content
					end
				end
				if !text.empty?
					card_text << "#{text}"
				end
			end
		end
		card_text.join("\n")
	end
	
	def get_flavor_text()
		row = @doc.css("#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_flavorRow").first
		flavor_text = []
		if row &&  flavor = row.css('#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_FlavorText').first
			flavor.children.each do | child |
				text = ''
				child.children.each do | kid |
					text += kid.content.gsub(/(\r\n|\n)\s*/,"") if kid.content
				end
				if !text.empty?
					flavor_text << "#{text}"
				end
			end
		end
		flavor_text.join("\n")
	end
	
	def get_current_set()
		row = @doc.css("#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_currentSetSymbol").first
	 	child = row.first_element_child
	 	kid = child.first_element_child
		kid['alt']
	end
	
	def get_rarity()
		row = @doc.css('#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_rarityRow').first
		rarity = nil
		if row && value = row.css('.value').first
			value.children.each do | child |
				if child.class==Nokogiri::XML::Element
					child.children.each do | kid |
						if kid.class==Nokogiri::XML::Text
							rarity = kid.content
						end
					end
				end
			end
		end
		rarity
	end
	
	def get_all_expansions()
		row = @doc.css("#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_otherSetsValue").first
		expansions = []
		row.children.each do | child |
			if child.class==Nokogiri::XML::Element
				kid = child.first_element_child
				expansions << kid['alt']
			end
		end
		expansions
	end
	
	def get_artist()
		row = @doc.css('#ctl00_ctl00_ctl00_MainContent_SubContent_SubContent_ArtistCredit').first
		child = row.first_element_child
	 	artist = child.content
	end
end

scraper=Scraper.new

p scraper.get_string_value("nameRow")
p scraper.get_alt_value("manaRow")
p scraper.get_string_value("cmcRow")
p scraper.get_string_value("typeRow")
puts scraper.get_card_text
puts scraper.get_flavor_text
p scraper.get_string_value("ptRow")
p scraper.get_current_set
puts scraper.get_rarity
p scraper.get_all_expansions
p scraper.get_string_value("numberRow")
p scraper.get_artist
