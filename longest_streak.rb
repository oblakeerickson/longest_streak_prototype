require 'octokit'
#require 'netrc'
require 'sequel'
require 'open-uri'
require 'json'

DB = Sequel.connect('sqlite://streak.db', :max_connections => 10, :pool_timeout => 10)

#for creating table automatically
DB.run "CREATE TABLE user (id VARCHAR(255), login VARCHAR(255), longest_streak INT(3)) "

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
    contributions = Contributions.new(@login)
    @streak = contributions.longest_streak
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
    puts "id: #{id} | login: #{login} | streak: #{streak}"
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

class Contributions
  def initialize(username)
    @data = calendar_data username
  end

  def longest_streak
    if @data != "error"
      data_string = remove_head_and_tail_brackets @data
      arr = to_array data_string
      daily_contributions = get_daily_contributions arr
      calc_longest_streak daily_contributions
    else
      0
    end
  end

  private

  def calendar_data(username)
    begin
      open("https://github.com/users/#{username}/contributions_calendar_data").read
    rescue
      "error"
    end
  end

  def to_array(data_string)
    arr =  data_string.split('],[')
  end

  def get_daily_contributions(arr)
    daily_contributions = Array.new
    arr.each do |a|
      v,k = a.split(',')
      daily_contributions << k.to_i
    end
    daily_contributions
  end

  def remove_head_and_tail_brackets(data_string)
    data_string[0..1] = ''
    length = data_string.length
    data_string[length-2..length] = ''
    data_string
  end

  def calc_longest_streak(arr)
    longest = 0
    current = 0
    arr.each do |a|
      if a > 0
        current = current + 1
      else
        if current > longest
          longest = current
        end
        current = 0
      end
      if current > longest
        longest = current
      end
    end
    longest
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

# contributions = Contributions.new('oasdasdlkjsflkjasdf')
# puts contributions.longest_streak


while rate_limit > 10 do
  list = @c.user_list last
  threads = []
  list.each { |user|
    threads << Thread.new() {
      my_user = User.new(user)
      #my_user.print
      my_user.save
    }
  }
  threads.each { |t| t.join }

  last = @c.last_user list
  #rate_limit = @c.rate_limit
  puts "last: #{last}"
end