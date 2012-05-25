require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'image_downloader'
require 'mysql'

$mysql_host="localhost"
$mysql_db="urlgrab"
$mysql_user="urlgrab"
$mysql_pwd="urlgrab"


#define a useragent for download operations
user_agent="https://github.com/hundfred/redgar| hundfred@s23.org"


#define some subroutines
###########################################################################

#sub insert_channel into db
def insert_channel(con,channel)
     sql="INSERT into irc_channel (channel) VALUES ('#{channel}');"
     res=con.query(sql)
end


#sub get_channel_id, if no channel_id is found in the db, an entry is made
def get_channel_id(con,channel)
	sql="SELECT id FROM irc_channel WHERE channel='#{channel}';"
	
	#check if channel exists in db
 	res=con.query(sql)
	if res.num_rows == 0
		insert_channel(con,channel)
        end 
	
	res=con.query(sql)
	channel_id="defined"	
        res.each_hash do |row|
 		channel_id=row['id']
    	end
	return channel_id
end

#sub insert_irc_handle into db
def insert_irc_handle(con,irc_handle)
	sql="INSERT into irc_handle (handle) VALUES ('#{irc_handle}');"
	res=con.query(sql)
end

#sub get_irc_handle_id, if no irc_handle_id is found, in the db, an entry is made
def  get_irc_handle_id(con,irc_handle)
        sql="SELECT id FROM irc_handle WHERE handle='#{irc_handle}';"
	
	#check, if irc_handle exists in db
	res=con.query(sql)
        if res.num_rows == 0
                insert_irc_handle(con,irc_handle)
        end

        res=con.query(sql)
        irc_handle_id="defined"
        res.each_hash do |row|
                irc_handle_id=row['id']
        end
        return irc_handle_id
end

#insert url into db
def insert_url(con,url,irc_handle,channel,title)
        title=con.escape_string(title)
	url=con.escape_string(url)
	channel_id=get_channel_id(con,channel)
        irc_handle_id=get_irc_handle_id(con,irc_handle)

        sql="INSERT into irc_url (url,handleid,channelid,title) VALUES ('#{url}','#{irc_handle_id}','#{channel_id}','#{title}');"
        res=con.query(sql)
end

#download
def download full_url, to_here
      File.umask(022)	
      writeOut = open(to_here, "wb")
      writeOut.write(open(full_url, "User-Agent" => "#{user_agent}").read)
      writeOut.close
end

#end-of-subroutines---------------------------------------------------------------


bot = Cinch::Bot.new do
  configure do |c|
    c.server = "localhost"
    c.channels = ["channel1","channel2"]
    c.nick = "redgar"
    c.user = "user"
    c.realname = "real"
  end

  on :channel do |m|
    irc_handle="#{m.user.nick}!#{m.user.user}@#{m.user.host}"
    channel=m.channel
    if m.message == "whoami"
        m.reply "#{irc_handle}"
#    elsif  #debug stuff
#     	m.message == "!chan"
#	channel_id=get_channel_id(con,channel)
#	m.reply "#{channel} ID:#{channel_id}"	
    else
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
	string="no-title"
  	if title != nil
  		string=String.new(title) #make sure that title is a string
  		#get rid of carriage return characters and so on
         		string.gsub!(/\n/, '')
  		string.gsub!(/\t/, '')
  		string.gsub!(/![a-zA-Z\d!$&,.]/,'') #i wonder i this works, there are still some spaces in the youtube-title
  		string.strip! #eleminate double spaces
  		m.reply "title: #{string}"
       	end
	con = Mysql::new($mysql_hostname,$mysql_db,$mysql_user,$mysql_pwd) #open db-connection
	#store url, title, channel, and irc_handle in db
	insert_url(con,url,irc_handle,channel,string)
	con.close	
      end
    end
  end
end

   
#start bot
bot.start
