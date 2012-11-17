module TrelloAuthorize
  include TrelloConfiguration
  include Trello::Authorization

  def authorize_on_trello(custom_auth_params={})
    auth_params = {}
    %w{developer_public_key access_token_key developer_secret}.each do |key|
      auth_params[key] = fetch_key(key, custom_auth_params)
    end

    init_trello(auth_params)
  end

  private

  def init_trello(auth_params)
    Trello::Authorization.const_set(:AuthPolicy, OAuthPolicy)

    OAuthPolicy.consumer_credential = OAuthCredential.new(auth_params["developer_public_key"], auth_params["developer_secret"])
    OAuthPolicy.token = OAuthCredential.new(auth_params["access_token_key"], nil)
  end

  def fetch_key(key, custom_auth_params)
    ENV[key] || default_authorization_params.merge(custom_auth_params)[key]
  end
end
