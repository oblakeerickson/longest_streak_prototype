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
    # client.user 'oblakeerickson'
    # response = client.last_response
    # etag = response.headers
    # etag[:'x-ratelimit-remaining']
  end

  def rate_limit
    @client.user 'oblakeerickson'
    response = @client.last_response
    rate_limit = response.headers[:'x-ratelimit-remaining'].to_i
  end

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