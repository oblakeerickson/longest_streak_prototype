require 'Octokit'
require 'netrc'
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
  end
  def id
    @id
  end
  def login
    @login
  end
  def print
    puts "id: #{id}"
    puts "login: #{login}"
  end
  def save
    DB.run("insert into user (id, login) values('#{id}', '#{login}')")
  end
end

class Page
  def initialize(username)
    page = open("https://github.com/#{username}").read
    chunk = chunk(page)
    @streak = get_streak(chunk)
  end

  def streak
    @streak
  end

  private

  def chunk(page)
    location = page.index '<div class="col contrib-streak">'
    page[location..location+100]
  end
  def get_streak(chunk)
    location = chunk.index 'days'
    @streak = chunk[location-4..location-2]
    if @streak[0,1] == '>'
      @streak[0] = ''
    end
    @streak
  end
  
end

@connection = Connection.new
list = @connection.user_list 0
user = list.first
my_user = User.new(user)
my_user.print
#my_user.save

@c = Connection.new
user = @c.user 'oblakeerickson'
puts user.id
puts user.location

page = Page.new(user.login)
puts page.streak


# @c = Connection.new
# list = @c.user_list 135
# last = @c.last_user list
# last = 0
# rate_limit = @c.rate_limit
# while rate_limit > 10 do
#   list = @c.user_list last
#   last = @c.last_user list
#   rate_limit = @c.rate_limit
#   puts "last: #{last} | rate limit: #{rate_limit}"
# end