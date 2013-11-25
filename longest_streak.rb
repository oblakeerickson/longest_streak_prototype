require 'Octokit'
require 'netrc'

class Connection
  def initialize
    username = get_username
    password = get_password
    @client = Octokit::Client.new :login => username, :password => password
  end
  def username
    @client.login
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