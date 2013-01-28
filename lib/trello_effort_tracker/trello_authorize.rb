module TrelloAuthorize
  include TrelloConfiguration
  include Trello::Authorization

  def authorize_on_trello(auth_params={})
    %w{developer_public_key access_token_key}.each do |key|
      auth_params[key] ||= ENV[key] || authorization_params_from_config_file[key]
    end

    Trello.configure do |config|
      config.developer_public_key = auth_params["developer_public_key"]
      config.member_token         = auth_params["access_token_key"]
    end
  end

end
