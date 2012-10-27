module TrelloAuthorize

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

end
