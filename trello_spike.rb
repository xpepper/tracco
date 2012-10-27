require 'trello'
require 'yaml'
require 'rainbow'

require 'chronic'

class Tracking
  def initialize(tracking_notification)
    @tracking_notification = tracking_notification
  end

  def date
    Chronic.parse(@tracking_notification.date)
  end

  def notifier
    @tracking_notification.member_creator
  end

  def card
    @tracking_notification.card
  end

  def raw_text
    @tracking_notification.data['text'].gsub("@trackinguser", "")
  end
end

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

init_trello

puts "connected...".color(:green)
tracker = Member.find("trackinguser")
tracker.notifications.each do |notification|
  tracking = Tracking.new(notification)
  begin
    puts "[#{tracking.date}] From #{tracking.notifier.username.color(:green)} on card '#{tracking.card.name.color(:yellow)}': #{tracking.raw_text}"
  rescue => e
    puts "skipping tracking: #{e.message}".color(:red)
  end
end

# {"text"=>"@trackinguser stima: 1h", "card"=>{"name"=>"Cambio password  - spostare l'utente al bottom della page", "idShort"=>294, "id"=>"5087b32add671fb9770021fe"}, "board"=>{"name"=>"Iterazione settimanale", "id"=>"502514e6af0f584e241bf9ec"}}
#
# iteration = Board.find("502514e6af0f584e241bf9ec")
# iteration_steps = iteration.lists
# iteration_steps.each do |step|
#   puts step.name.upcase
#   step.cards.each do |user_story|
#     puts "\t" + user_story.name
#   end
# end
