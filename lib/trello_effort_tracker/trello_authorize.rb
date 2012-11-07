module TrelloAuthorize
  include Trello::Authorization

  def init_trello(auth_params)
    developer_public_key  = ENV["developer_public_key"] || auth_params["developer_public_key"]
    access_token_key      = ENV["access_token_key"]     || auth_params["access_token_key"]
    developer_secret      = ENV["developer_secret"]     || auth_params["developer_secret"]

    Trello::Authorization.const_set(:AuthPolicy, OAuthPolicy)

    OAuthPolicy.consumer_credential = OAuthCredential.new(developer_public_key, developer_secret)
    OAuthPolicy.token = OAuthCredential.new(access_token_key, nil)
  end

end
