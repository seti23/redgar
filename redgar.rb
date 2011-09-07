require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'image_downloader'
user_agent="https://github.com/hundfred/redgar| hundfred@s23.org"
   def download full_url, to_here
      File.umask(022)	
      writeOut = open(to_here, "wb")
      writeOut.write(open(full_url, "User-Agent" => "#{user_agent}").read)
      writeOut.close
    end

bot = Cinch::Bot.new do
  configure do |c|
#    c.server = "irc.efnet.org"
    c.server="localhost"
    c.channels = ["#seti23" ]
    c.nick = "redgar"
    c.user = "user"
    c.realname = "real"
  end

  on :channel do |m|
    urls = URI.extract(m.message, "http")
    if not urls.empty?
        #url is pointing to an image -> download it
	url=String.new(urls[0])
	reg='.+\.(?:jpg|jpeg|gif|png)$'
	if url.downcase =~ /#{reg}/
		#extract filename from url
		elements=url.split('/')
                filename=elements[elements.length-1]
                m.reply "that looks like an image! downloading ..."
		download(url ,"images/#{filename}")
	end
	
	#extract title
	doc = Nokogiri::HTML(open(urls[0],"User-Agent" => "#{user_agent}"))
	title=doc.at_css("title")
	if title != nil
		string=String.new(title) #make sure that title is a string
		#get rid of carriage return characters and so on
       		string.gsub!(/\n/, '')
		string.gsub!(/\t/, '')
		string.gsub!(/![a-zA-Z\d!$&,.]/,'') #i wonder i this works, there are still some spaces in the youtube-title
		string.strip! #eleminate double spaces
		m.reply "title: #{string}"
     	end
    end
  end
end

   
#start bot
bot.start
