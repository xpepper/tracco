require 'spec_helper'

describe Tracco do

  before(:each) do
    @original = ENV["TRACCO_ENV"]
  end

  after(:each) do
    ENV["TRACCO_ENV"] = @original
  end

  describe ".environment" do

    it "tells the current environment name" do
      ENV['TRACCO_ENV'] = "any_env"

      Tracco.environment.should == "any_env"
    end
  end

  describe ".environment=" do
    it "sets an environment variable" do
      Tracco.environment = "an_env"

      Tracco.environment.should == "an_env"
      ENV['TRACCO_ENV'].should == "an_env"
    end
  end

end
