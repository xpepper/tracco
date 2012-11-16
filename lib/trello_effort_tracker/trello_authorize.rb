module TrelloAuthorize
  include TrelloConfiguration
  include Trello::Authorization

  def authorize_on_trello(custom_auth_params={})
    auth_params = default_authorization_params.merge(custom_auth_params)
    init_trello(auth_params)
  end

  private

  def init_trello(auth_params)
    developer_public_key  = ENV["developer_public_key"] || auth_params["developer_public_key"]
    access_token_key      = ENV["access_token_key"]     || auth_params["access_token_key"]
    developer_secret      = ENV["developer_secret"]     || auth_params["developer_secret"]

    Trello::Authorization.const_set(:AuthPolicy, OAuthPolicy)

    OAuthPolicy.consumer_credential = OAuthCredential.new(developer_public_key, developer_secret)
    OAuthPolicy.token = OAuthCredential.new(access_token_key, nil)
  end

end
