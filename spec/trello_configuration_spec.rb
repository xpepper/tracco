require 'spec_helper'
require 'trello'

describe TrelloConfiguration do
  include TrelloConfiguration

  describe "#authorization_params_from_config_file" do
    it "loads the default trello auth params from config yml" do
      config_hash = {"trello" => { "developer_public_key" => "any_dpk", "access_token_key" => "any_atk", "developer_secret" => "any_ds"} }
      YAML.should_receive(:load_file).with("config/config.yml").and_return(config_hash)

      authorization_params_from_config_file["developer_public_key"].should == "any_dpk"
      authorization_params_from_config_file["access_token_key"].should == "any_atk"
      authorization_params_from_config_file["developer_secret"].should == "any_ds"
    end    
  end
  
  describe "#tracker_username" do
    before(:each) do
      @original = ENV["tracker_username"]
    end
    
    after(:each) do
      ENV["tracker_username"] = @original
    end
    
    it "searches for the trello tracker username first from an env var" do
      ENV["tracker_username"] = "my_tracker"
      YAML.should_receive(:load_file).never
    
      tracker_username.should == "my_tracker"
    end
    it "searches for the trello tracker username in the config yml file if the env var is not set" do
      ENV["tracker_username"] = nil
      config_hash = {"tracker_username" => "my_trello_tracker" }
      YAML.should_receive(:load_file).with("config/config.yml").and_return(config_hash)
      
      tracker_username.should == "my_trello_tracker"
    end
    
  end

end
