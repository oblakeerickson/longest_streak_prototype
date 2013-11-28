require 'Octokit'
require 'netrc'
require 'sequel'
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

# get a chunk of users
# for each user insert or update them
# repeat

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

@connection = Connection.new
list = @connection.user_list 0
user = list.first
my_user = User.new(user)
my_user.print
my_user.save
puts user.gravatar_id
puts user.followers

#DB.run("insert into user (id, login) values('#{user.id}', '#{user.login}')")


# @c = Connection.new
# user = @c.user 'oblakeerickson'
# puts user.email

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