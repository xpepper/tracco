require 'trello'

module TrelloAuthorize
  include TrelloConfiguration
  include Trello::Authorization

  def init_trello
    developer_public_key  = configuration["trello"]["developer_public_key"]
    access_token_key      = configuration["trello"]["access_token_key"]
    developer_secret      = configuration["trello"]["developer_secret"]

    Trello::Authorization.const_set(:AuthPolicy, OAuthPolicy)

    OAuthPolicy.consumer_credential = OAuthCredential.new(developer_public_key, developer_secret)
    OAuthPolicy.token = OAuthCredential.new(access_token_key, nil)
  end

end
