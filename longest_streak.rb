require 'octokit'
#require 'netrc'
require 'sequel'
require 'open-uri'
DB = Sequel.connect('sqlite://streak.db')

class Connection
  def initialize
    username = get_username
    password = get_password
    @client = Octokit::Client.new :login => username, :password => password
  end
  def username
    @client.login
  end

  def user(username)
    @client.user username
  end

  def rate_limit
    @client.user 'oblakeerickson'
    response = @client.last_response
    @rate_limit = response.headers[:'x-ratelimit-remaining'].to_i
  end

  def user_list(since)
    @list = @client.all_users :since => since
  end

  def last_user(list)
    list.last.id
  end

  # def get_all_users
  #   while @rate_limit > 10 do 
  #     list = user_list last
  #     last = last_user list
  #     @rate_limit = rate_limit
  #   end
  # end

  private
    def get_username
      username_file = '.username'
      File.read(username_file).chomp
    end
    def get_password
      password_file = '.password'
      File.read(password_file).chomp
    end
end

class User
  def initialize(user)
    @id = user.id
    @login = user.login
    page = Page.new(@login)
    @streak = page.streak
  end
  def id
    @id
  end
  def login
    @login
  end
  def streak
    @streak
  end
  def print
    puts "id: #{id}"
    puts "login: #{login}"
    puts "streak: #{streak}"
  end
  def save
    DB.run("insert into user (id, login, longest_streak) values('#{id}', '#{login}', '#{streak}')")
  end
end

class Page
  def initialize(username)
    page = page username
    chunk = chunk(page)
    if chunk != nil
      @streak = get_streak(chunk)
    else 
      @streak = 0
    end
  end

  def streak
    @streak
  end

  private

  def page(username)
    begin 
      open("https://github.com/#{username}").read
    rescue
      "error"
    end
  end

  def chunk(page)
    location = page.index '<div class="col contrib-streak">'
    if location != nil
      page[location..location+100]
    end
  end
  def get_streak(chunk)
    location = chunk.index 'days'
    @streak = chunk[location-4..location-2]
    if @streak[0,1] == '"'
      @streak[0] = ''
    end
    if @streak[0,1] == '>'
      @streak[0] = ''
    end
    @streak
  end
  
end

# @connection = Connection.new
# list = @connection.user_list 0
# user = list.first
# my_user = User.new(user)
# my_user.print
# my_user.save

# @c = Connection.new
# user = @c.user 'oblakeerickson'
# puts user.id
# puts user.location

# page = Page.new(user.login)
# puts page.streak


@c = Connection.new
last = 0
rate_limit = 5000

while rate_limit > 10 do
  list = @c.user_list last
  threads = []
  list.each { |user|
    threads << Thread.new() {
      my_user = User.new(user)
      my_user.print
      #my_user.save
    }
  }
  threads.each { |t| t.join }

  last = @c.last_user list
  rate_limit = @c.rate_limit
  puts "last: #{last} | rate limit: #{rate_limit}"
end