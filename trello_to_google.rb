# gem install google_drive
# gem install highline

require 'yaml'
require 'trello'
require "google_drive"
require 'highline/import'
require 'rainbow'


columns = {
  iteration:        1,
  project:          2,
  id:               3,
  user_story_name:  4,
  status:           5,
  planned_effort:   6,
  prev_spent:       7,
  total_effort:     8,
  notes:            9
}

def init_trello
  config = YAML.load_file("config.yml")

  developer_public_key = config["trello"]["developer_public_key"]
  access_token_key = config["trello"]["access_token_key"]
  developer_secret = config["trello"]["developer_secret"]
  
  include Trello
  include Trello::Authorization

  Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

  OAuthPolicy.consumer_credential = OAuthCredential.new developer_public_key, developer_secret
  OAuthPolicy.token = OAuthCredential.new access_token_key, nil
end

def open_google_docs_session(default_email="pietro.dibello@xpeppers.com")
  username = ask("Enter google docs username: ") { |q| q.default = default_email }
  password = ask("Enter google docs password: ") { |q| q.echo = false }

  GoogleDrive.login(username, password)
end

init_trello
session = open_google_docs_session
puts "connected...".color(:green) if session


spreadsheet = session.spreadsheet_by_title("Backlog Futur3")
backlog = spreadsheet.worksheet_by_title("iterazioni")

team = Organization.find("futur3")
iteration = Board.find("4fdedc649b86ad81030e2e09")
iteration_steps = iteration.lists

index = 3 # skip the headers
iteration_steps.each do |step|
  step.cards.each do |user_story|
    print ".".color(:green)
    backlog[index,columns[:project]] = user_story.labels.map(&:name).join(" - ")
    backlog[index,columns[:user_story_name]] = user_story.name
    backlog[index,columns[:status]] = step.name
    index += 1
  end
end

backlog.save
puts "[DONE]".color(:green)