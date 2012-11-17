module TrelloAuthorize
  include TrelloConfiguration
  include Trello::Authorization

  def authorize_on_trello(auth_params={})
    %w{developer_public_key access_token_key developer_secret}.each do |key|
      auth_params[key] ||= ENV[key] || authorization_params_from_config_file[key]
    end

    init_trello(auth_params)
  end

  private

  def init_trello(auth_params)
    Trello::Authorization.const_set(:AuthPolicy, OAuthPolicy)

    OAuthPolicy.consumer_credential = OAuthCredential.new(auth_params["developer_public_key"], auth_params["developer_secret"])
    OAuthPolicy.token = OAuthCredential.new(auth_params["access_token_key"], nil)
  end
end
