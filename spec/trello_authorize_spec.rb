require 'spec_helper'
require 'trello'

describe TrelloAuthorize do
  include Trello::Authorization
  include TrelloAuthorize

  before(:each) do
    keep_original_auth_envs
  end

  after(:each) do
    reset_original_auth_envs
  end

  describe "#authorize_on_trello" do

    it "creates oath credentials using auth params given as params when present as arguments, ignoring env vars or config YML vars" do
      ENV["developer_public_key"] = ENV["access_token_key"] = ENV["developer_secret"] = "anything"
      YAML.should_receive(:load_file).never

      authorize_on_trello("developer_public_key" => "custom_dpk", "access_token_key" => "custom_atk", "developer_secret" => "custom_ds")

      Trello::Authorization::OAuthPolicy.consumer_credential.key.should == "custom_dpk"
      Trello::Authorization::OAuthPolicy.consumer_credential.secret.should == "custom_ds"
      Trello::Authorization::OAuthPolicy.token.key.should == "custom_atk"
    end

    it "creates oath credentials using auth params taken from env variables when auth params are not given as arguments" do
      ENV["developer_public_key"] = "my_dpk"
      ENV["access_token_key"]     = "my_atk"
      ENV["developer_secret"]     = "my_ds"

      YAML.should_receive(:load_file).never

      authorize_on_trello("any" => "thing")

      Trello::Authorization::OAuthPolicy.consumer_credential.key.should == "my_dpk"
      Trello::Authorization::OAuthPolicy.consumer_credential.secret.should == "my_ds"
      Trello::Authorization::OAuthPolicy.token.key.should == "my_atk"
    end

    it "creates oath credentials using auth params from config file when auth env variables are not set" do
      ENV["developer_public_key"] = ENV["access_token_key"] = ENV["developer_secret"] = nil

      config_hash = {"trello" => { "developer_public_key" => "any_dpk", "access_token_key" => "any_atk", "developer_secret" => "any_ds"}}
      YAML.should_receive(:load_file).with("config/config.yml").and_return(config_hash)

      authorize_on_trello("any" => "thing")

      Trello::Authorization::OAuthPolicy.consumer_credential.key.should == "any_dpk"
      Trello::Authorization::OAuthPolicy.consumer_credential.secret.should == "any_ds"
      Trello::Authorization::OAuthPolicy.token.key.should == "any_atk"
    end

  end

  private

  def keep_original_auth_envs
    @original_developer_public_key = ENV["developer_public_key"]
    @original_access_token_key     = ENV["access_token_key"]
    @original_developer_secret     = ENV["developer_secret"]
  end

  def reset_original_auth_envs
    ENV["developer_public_key"] = @original_developer_public_key
    ENV["access_token_key"]     = @original_access_token_key
    ENV["developer_secret"]     = @original_developer_secre
  end
end
