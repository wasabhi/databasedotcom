require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Client do

  describe "configuration" do
    context "from environment variables" do
      before do
        ENV['DATABASEDOTCOM_CLIENT_ID'] = "client_id"
        ENV['DATABASEDOTCOM_CLIENT_SECRET'] = "client_secret"
        ENV['DATABASEDOTCOM_DEBUGGING'] = "true"
        ENV['DATABASEDOTCOM_HOST'] = "foo.bar"
        ENV['DATABASEDOTCOM_VERSION'] = '99'
        ENV['DATABASEDOTCOM_SOBJECT_MODULE'] = "Databasedotcom::Sobject"
        ENV['DATABASEDOTCOM_CA_FILE'] = "ca/file.cert"
        ENV['DATABASEDOTCOM_VERIFY_MODE'] = "1"
        ENV['DATABASEDOTCOM_BATCH_SIZE'] = '200'
        ENV['DATABASEDOTCOM_READ_TIMEOUT'] = "600"
        @client = Databasedotcom::Client.new
      end

      after do
        ENV.delete 'DATABASEDOTCOM_CLIENT_ID'
        ENV.delete 'DATABASEDOTCOM_CLIENT_SECRET'
        ENV.delete 'DATABASEDOTCOM_DEBUGGING'
        ENV.delete 'DATABASEDOTCOM_HOST'
        ENV.delete 'DATABASEDOTCOM_VERSION'
        ENV.delete 'DATABASEDOTCOM_SOBJECT_MODULE'
        ENV.delete "DATABASE_COM_URL"
        ENV.delete "DATABASEDOTCOM_CA_FILE"
        ENV.delete "DATABASEDOTCOM_VERIFY_MODE"
        ENV.delete "DATABASEDOTCOM_BATCH_SIZE"
        ENV.delete 'DATABASEDOTCOM_READ_TIMEOUT'
      end

      it "takes configuration information from the environment, if present" do
        @client.client_id.should == "client_id"
        @client.client_secret.should == "client_secret"
        @client.host.should == "foo.bar"
        @client.debugging.should be_true
        @client.version.should == '99'
        @client.sobject_module.should == "Databasedotcom::Sobject"
        @client.ca_file.should == "ca/file.cert"
        @client.verify_mode.should == 1
        @client.batch_size.should == '200'
        @client.read_timeout.should == 600
      end

      it "takes configuration information from a URL" do
        ENV["DATABASE_COM_URL"] = "orce://prerelna1.pre.salesforce.com?user=app189664@heroku.com&password=WeOpvh31ppK&oauth_key=3MVGDo9lKcPoNINVBL1L01Rvbe7zvgN2O760vd1OfUswGppw0qSj5Yg74yaFIa_YMM9TGFVSt3jcy54l87Cw1vS&oauth_secret=624857638194281274122"
        @client = Databasedotcom::Client.new
        @client.client_id.should == "3MVGDo9lKcPoNINVBL1L01Rvbe7zvgN2O760vd1OfUswGppw0qSj5Yg74yaFIa_YMM9TGFVSt3jcy54l87Cw1vS"
        @client.client_secret.should == "624857638194281274122"
        @client.username.should == "app189664@heroku.com"
        @client.password.should == "WeOpvh31ppK"
        @client.host.should == "prerelna1.pre.salesforce.com"
        @client.sobject_module.should == "Databasedotcom::Sobject"
        @client.ca_file.should == "ca/file.cert"
        @client.verify_mode.should == 1
      end
    end

    context "from a yaml file" do
      it "takes configuration information from the specified file" do
        client = Databasedotcom::Client.new(File.join(File.dirname(__FILE__), "../fixtures/databasedotcom.yml"))
        client.client_id.should == "client_id"
        client.client_secret.should == "client_secret"
        client.debugging.should be_true
        client.host.should == "bro.baz"
        client.version.should == '88'
        client.ca_file.should == "other/ca/file.cert"
        client.verify_mode.should == 1
      end
    end

    context "from a hash" do
      it "takes configuration information from the hash" do
        client = Databasedotcom::Client.new("client_id" => "client_id", "client_secret" => "client_secret", "debugging" => true, "host" => "foo.baz", "version" => "77", "ca_file" => "alt/ca/file.cert", "verify_mode" => 3, "batch_size" => 500, "read_timeout" => 600)
        client.client_id.should == "client_id"
        client.client_secret.should == "client_secret"
        client.debugging.should be_true
        client.host.should == "foo.baz"
        client.version.should == "77"
        client.ca_file.should == "alt/ca/file.cert"
        client.verify_mode.should == 3
        client.batch_size.should == 500
        client.read_timeout.should == 600
      end

      it "accepts symbols in the hash" do
        client = Databasedotcom::Client.new(:client_id => "client_id", :client_secret => "client_secret", :debugging => true, :host => "foo.baz", :version => "77", :ca_file => "alt/ca/file.cert", :verify_mode => 3, :batch_size => 500, :read_timeout => 600)
        client.client_id.should == "client_id"
        client.client_secret.should == "client_secret"
        client.debugging.should be_true
        client.host.should == "foo.baz"
        client.version.should == "77"
        client.ca_file.should == "alt/ca/file.cert"
        client.verify_mode.should == 3
        client.batch_size.should == 500
        client.read_timeout.should == 600
      end
    end

    describe "defaults" do
      before do
        @client = Databasedotcom::Client.new(:client_id => "client_id", :client_secret => "client_secret")
      end

      it "defaults to the standard salesforce host" do
        @client.host.should == "login.salesforce.com"
      end

      it "defaults to no debugging output" do
        @client.debugging.should be_false
      end

      it "defaults to no special ca file" do
        @client.ca_file.should be_nil
      end

      it "defaults to no special verify mode" do
        @client.verify_mode.should be_nil
      end

      it "defaults to no special batch size" do
        @client.batch_size.should be_nil
      end
    end

    describe "precedence" do
      before do
        ENV['DATABASEDOTCOM_CLIENT_ID'] = "env_client_id"
        ENV['DATABASEDOTCOM_CLIENT_SECRET'] = "env_client_secret"
        ENV['DATABASEDOTCOM_DEBUGGING'] = "foo"
        ENV['DATABASEDOTCOM_HOST'] = "foo.bar"
        ENV['DATABASEDOTCOM_VERSION'] = '99'
      end

      after do
        ENV.delete 'DATABASEDOTCOM_CLIENT_ID'
        ENV.delete 'DATABASEDOTCOM_CLIENT_SECRET'
        ENV.delete 'DATABASEDOTCOM_DEBUGGING'
        ENV.delete 'DATABASEDOTCOM_HOST'
        ENV.delete 'DATABASEDOTCOM_VERSION'
      end

      it "prefers the environment configuration to the YAML configuration" do
        client = Databasedotcom::Client.new(File.join(File.dirname(__FILE__), "../fixtures/databasedotcom.yml"))
        client.client_id.should == "env_client_id"
        client.client_secret.should == "env_client_secret"
        client.debugging.should == "foo"
        client.host.should == "foo.bar"
        client.version.should == '99'
      end
    end
  end

  describe "authentication" do
    before do
      @client = Databasedotcom::Client.new(File.join(File.dirname(__FILE__), "../fixtures/databasedotcom.yml"))
      @client.debugging = false
      @access_token = "00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs"
      @org_id = "00Dx0000000BV7z"
      @user_id = "005x00000012Q9P"
    end

    describe "common behavior" do
      before do
        response_body = File.read(File.join(File.dirname(__FILE__), '..', "fixtures/auth_success_response.json"))
        stub_request(:post, "https://bro.baz/services/oauth2/token?grant_type=password&client_id=client_id&client_secret=client_secret&username=username&password=password").to_return(:body => response_body, :status => 200)
        response_body = File.read(File.join(File.dirname(__FILE__), '..', "fixtures/services_data_success_response.json"))
        stub_request(:get, "https://na1.salesforce.com/services/data").to_return(:body => response_body, :status => 200)
      end

      it "uses the configured ca file" do
        Net::HTTP.any_instance.should_receive(:"ca_file=").with("other/ca/file.cert")
        @client.authenticate(:username => "username", :password => "password")
      end

      it "uses the configured verify mode" do
        Net::HTTP.any_instance.should_receive(:"verify_mode=").with(OpenSSL::SSL::VERIFY_PEER)
        @client.authenticate(:username => "username", :password => "password")
      end

      it "defaults to version 22.0" do
        @client.version = nil
        @client.authenticate(:username => "username", :password => "password")
        @client.version.should == "22.0"
      end

    end

    context "with a username and password" do
      it "requests autonomous client authentication" do
        response_body = File.read(File.join(File.dirname(__FILE__), '..', "fixtures/auth_success_response.json"))
        stub_request(:post, "https://bro.baz/services/oauth2/token?grant_type=password&client_id=client_id&client_secret=client_secret&username=username&password=password").to_return(:body => response_body, :status => 200)

        lambda {
          @client.authenticate(:username => "username", :password => "password")
        }.should_not raise_error

        WebMock.should have_requested(:post, "https://bro.baz/services/oauth2/token?grant_type=password&client_id=client_id&client_secret=client_secret&username=username&password=password")
      end

      it "URL encodes the username and password" do
        response_body = File.read(File.join(File.dirname(__FILE__), '..', "fixtures/auth_success_response.json"))
        stub_request(:post, "https://bro.baz/services/oauth2/token?grant_type=password&client_id=client_id&client_secret=client_secret&username=user%26name&password=pass%26word").to_return(:body => response_body, :status => 200)
        @client.authenticate(:username => "user&name", :password => "pass&word")
        WebMock.should have_requested(:post, "https://bro.baz/services/oauth2/token?grant_type=password&client_id=client_id&client_secret=client_secret&username=user%26name&password=pass%26word")
      end

      context "with a success response" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), '..', "fixtures/auth_success_response.json"))
          stub_request(:post, "https://bro.baz/services/oauth2/token?grant_type=password&client_id=client_id&client_secret=client_secret&username=username&password=password").to_return(:body => response_body, :status => 200)
        end

        it "parses response and obtains the token" do
          @client.authenticate(:username => "username", :password => "password")
          @client.oauth_token.should == @access_token
        end

        it "remembers the instance url" do
          @client.authenticate(:username => "username", :password => "password")
          @client.instance_url.should == "https://na1.salesforce.com"
        end

        it "returns the token" do
          @client.authenticate(:username => "username", :password => "password").should == @access_token
        end

        it "sets username and password" do
          @client.authenticate(:username => "username", :password => "password")
          @client.username.should == "username"
          @client.password.should == "password"
        end

        it "sets the user_id and org_id" do
          @client.authenticate(:username => "username", :password => "password")
          @client.user_id.should == @user_id
          @client.org_id.should == @org_id
        end
      end

      context "with an error response" do
        before do
          @response_body = File.read(File.join(File.dirname(__FILE__), '..', "fixtures/auth_error_response.json"))
          stub_request(:post, "https://bro.baz/services/oauth2/token?grant_type=password&client_id=client_id&client_secret=client_secret&username=username&password=password").to_return(:body => @response_body, :status => 400)
        end

        it "raises Databasedotcom::SalesForceError" do
          lambda {
            @client.authenticate(:username => "username", :password => "password")
          }.should raise_error(Databasedotcom::SalesForceError)
        end
      end
    end

    context "with an omniauth response" do
      before do
        @response = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', "fixtures/omniauth_response.json")))
      end

      it "parses the response token from the ominauth hash" do
        @client.authenticate(@response)
        @client.oauth_token.should == "access_token"
      end

      it "remembers the instance url" do
        @client.authenticate(@response)
        @client.instance_url.should == "https://na1.salesforce.com"
      end

      it "remembers the refresh token" do
        @client.authenticate(@response)
        @client.refresh_token.should == "refresh_token"
      end

      it "returns the token" do
        @client.authenticate(@response).should == "access_token"
      end

      it "sets user id and org id" do
        @client.authenticate(@response)
        @client.org_id.should == @org_id
        @client.user_id.should == @user_id
      end
    end

    context "with a previously obtained access token" do
      context "with valid parameters" do
        it "should set the access token to the token that is passed in" do
          @client.authenticate(:token => "obtained_access_token", :instance_url => "https://na1.salesforce.com")
          @client.oauth_token.should == "obtained_access_token"
        end

        it "sets the instance url" do
          @client.authenticate(:token => "obtained_access_token", :instance_url => "https://na1.salesforce.com")
          @client.instance_url.should == "https://na1.salesforce.com"
        end

        it "sets the refresh token" do
          @client.authenticate(:token => "obtained_access_token", :instance_url => "https://na1.salesforce.com", :refresh_token => "refresh_token")
          @client.refresh_token.should == "refresh_token"
        end

        it "returns the token" do
          @client.authenticate(:token => "foo", :instance_url => "https://na1.salesforce.com").should == "foo"
        end

        it "does not set user_id" do
          @client.authenticate(:token => "foo", :instance_url => "https://na1.salesforce.com").should == "foo"
          @client.user_id.should be_nil
        end

        it "loads the org_id upon request" do
          @client.should_receive(:query).with("select id from Organization").and_return(["Id" => @org_id])
          @client.authenticate(:token => "foo", :instance_url => "https://na1.salesforce.com").should == "foo"
          @client.org_id.should == @org_id
        end
      end

      context "with invalid parameters" do
        it "requires a token" do
          lambda {
            @client.authenticate(:instance_url => "https://na1.salesforce.com")
          }.should raise_error(ArgumentError)
        end

        it "requires an instance_url" do
          lambda {
            @client.authenticate(:token => "foo")
          }.should raise_error(ArgumentError)
        end
      end
    end
  end

  context "with an authenticated client" do
    before do
      @client = Databasedotcom::Client.new(File.join(File.dirname(__FILE__), "../fixtures/databasedotcom.yml"))
      @client.debugging = false
      @client.version = "23.0"
      @client.authenticate(:token => "foo", :instance_url => "https://na1.salesforce.com")
    end

    describe "#list_sobjects" do
      context "with a successful request" do
        before do
          @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/list_sobjects_success_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects").to_return(:body => @response_body, :status => 200)
        end

        it "returns an array of available sobjects with a given version" do
          @client.list_sobjects.should == ["Account"]
        end
      end

      context "with a failed request" do
        before do
          @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/list_sobjects_error_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects").to_return(:body => @response_body, :status => 400)
        end

        it "raises an Databasedotcom::Sobject::SalesForceError" do
          lambda {
            @client.list_sobjects
          }.should raise_error(Databasedotcom::SalesForceError)
        end
      end
    end

    describe "#describe_sobjects" do
      context "with a successful request" do
        before do
          @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/describe_sobjects_success_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects").to_return(:body => @response_body, :status => 200)
        end

        it "returns an array of hashes listing the properties for available sobjects with a given version" do
          @client.describe_sobjects.first["name"].should == "Account"
          @client.describe_sobjects.first["createable"].should be_true
        end
      end

      context "with a failed request" do
        before do
          @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/describe_sobjects_error_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects").to_return(:body => @response_body, :status => 400)
        end

        it "raises a Databasedotcom::Sobject::SalesForceError" do
          lambda {
            @client.describe_sobjects
          }.should raise_error(Databasedotcom::SalesForceError)
        end
      end
    end

    describe "#materialize" do
      before do
        @client.stub(:describe_sobject).and_return({"fields" => [], "bar" => "baz"})
      end
      after do
        Object.send(:remove_const, "AccountThing") if Object.const_defined?("AccountThing")
      end

      it "dynamically creates a ruby class for the sobject" do
        clazz = @client.materialize("AccountThing")
        clazz.class.should == Class
        clazz.superclass.should == Databasedotcom::Sobject::Sobject
        clazz.name.should == "AccountThing"
      end

      context "with a lowercase class name" do
        it "materializes the class with a capitalized name" do
          clazz = @client.materialize("lowerThing")
          clazz.class.should == Class
          clazz.name.should == "LowerThing"
        end

        it "sets the sobject_name of the class to the lowercase name" do
          clazz = @client.materialize("lowerThing")
          clazz.sobject_name.should == "lowerThing"
        end
      end

      describe "namespacing" do
        module TestModule
        end

        it "places the class in the module specified to the client" do
          @client.sobject_module = TestModule
          clazz = @client.materialize("AccountThing")
          clazz.name.should == "TestModule::AccountThing"
          @client.sobject_module = nil
        end

        it "defaults to Object" do
          clazz = @client.materialize("AccountThing")
          clazz.name.should == "AccountThing"
        end

        it "materializes into the specified module even if a constant of the same name exists in an ancestor module" do
          @client.sobject_module = TestModule
          clazz = @client.materialize("Array")
          clazz.name.should == "TestModule::Array"
          @client.sobject_module = nil
        end
      end

      it "sets the client on the new classes" do
        clazz = @client.materialize("AccountThing")
        clazz.client.should == @client
      end

      it "can create multiple dynamic ruby classes" do
        classes = @client.materialize(%w(Account Vehicle))
        classes.length.should == 2
        classes.each do |clazz|
          clazz.class.should == Class
          clazz.superclass.should == Databasedotcom::Sobject::Sobject
        end
      end

      it "caches the Sobject description on the materialized class" do
        @client.should_receive(:describe_sobject).with("AccountThing").and_return({"fields" => [], "bar" => "baz"})
        clazz = @client.materialize("AccountThing")
        clazz.description.should == {"fields" => [], "bar" => "baz"}
      end

      it "does not try to materialize classes that are defined" do
        lambda {
          @client.materialize(%w(Account Contact String))
        }.should_not raise_error
      end
    end

    describe "#describe_sobject" do
      context "with a known sobject type" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/sobject_describe_success_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/describe").to_return(:body => response_body, :status => 200)
        end

        it "requests fields and metadata for the sobject type" do
          @client.describe_sobject("Whizbang")
          WebMock.should have_requested(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/describe")
        end

        it "returns the server's JSON response as a hash" do
          hash = @client.describe_sobject("Whizbang")
          hash.should be_instance_of(Hash)
          hash["name"].should == "Whizbang"
        end
      end

      context "with an unknown sobject type" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/sobject_describe_error_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects/Foo/describe").to_return(:body => response_body, :status => 400)
        end

        it "raises Databasedotcom::SalesForceError" do
          lambda {
            @client.describe_sobject("Foo")
          }.should raise_error(Databasedotcom::SalesForceError)
        end
      end
    end

    context "with a non-materialized class" do

      context "specified by the request" do
        before do
          @client.should_receive(:find_or_materialize).with("OtherWhizbang")
        end

        describe "#find" do
          it "materializes the class for the returned objects" do
            response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/sobject_find_success_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects/OtherWhizbang/23foo").to_return(:body => response_body, :status => 200)
            @client.find("OtherWhizbang", "23foo") rescue nil
          end
        end

        describe "#create" do
          it "materializes the class for the returned objects" do
            response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/create_success_response.json"))
            stub_request(:post, "https://na1.salesforce.com/services/data/v23.0/sobjects/OtherWhizbang").to_return(:body => response_body, :status => 201)
            @client.create("OtherWhizbang", "Name" => "foo") rescue nil
          end
        end

        describe "#update" do
          it "materializes the class for the returned objects" do
            stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/OtherWhizbang/rid").to_return(:body => nil, :status => 204)
            @client.update("OtherWhizbang", "rid", "{\"Name\":\"update\"}") rescue nil
          end
        end

        describe "#upsert" do
          it "materializes the class for the returned objects" do
            response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/upsert_created_success_response.json"))
            stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/OtherWhizbang/Name/somename").to_return(:body => response_body, :status => 201)
            @client.upsert("OtherWhizbang", "Name", "somename", "Name" => "newname") rescue nil
          end
        end
      end

      context "specified by the response" do
        before do
          @client.should_receive(:find_or_materialize).with("Whizbang")
        end

        describe "#query" do
          it "materializes the class for the returned objects" do
            response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_success_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/query?q=SELECT+Checkbox_Label+FROM+Whizbang").to_return(:body => response_body, :status => 200)
            @client.query("SELECT Checkbox_Label FROM Whizbang") rescue nil
          end
        end

        describe "#search" do
          it "materializes the class for the returned objects" do
            response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/search_success_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/search?q=foo").to_return(:body => response_body, :status => 200)
            @client.search("foo") rescue nil
          end
        end
      end
    end

    context "with a materialized class" do
      module MySobjects
        class Whizbang < Databasedotcom::Sobject::Sobject
        end
      end

      before do
        response = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/sobject_describe_success_response.json"))
        stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/describe").to_return(:body => response, :status => 200)
        @client.sobject_module = MySobjects
        MySobjects::Whizbang.client = @client
        MySobjects::Whizbang.materialize("Whizbang")
      end

      after(:each) do
        @client.sobject_module = nil
      end

      describe "#find_or_materialize" do
        module MyTestModule
          module Submodule
            class Something;
            end
          end
        end

        before do
          @client.should_not_receive(:materialize)
        end

        after(:each) do
          @client.sobject_module = nil
        end

        it "finds a Class" do
          @client.send(:find_or_materialize, MyTestModule::Submodule::Something).should == MyTestModule::Submodule::Something
        end

        it "finds a fully-qualified class name" do
          @client.sobject_module = MyTestModule::Submodule
          @client.send(:find_or_materialize, "MyTestModule::Submodule::Something").should == MyTestModule::Submodule::Something
        end

        it "finds a class name relative to the sobject_module" do
          @client.sobject_module = MyTestModule::Submodule
          @client.send(:find_or_materialize, "Something").should == MyTestModule::Submodule::Something
        end

        it "raises ArgumentError if a fully-qualified class name is passed that is not equivalent to sobject_namespace" do
          lambda {
            @client.send(:find_or_materialize, "Foo::Bar")
          }.should raise_error(ArgumentError)
        end
      end

      describe "#find" do
        context "with a valid id" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/sobject_find_success_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/23foo").to_return(:body => @response_body, :status => 200)
          end

          it "returns the found instance" do
            @client.find(MySobjects::Whizbang, "23foo").should be_an_instance_of(MySobjects::Whizbang)
          end

          it "initializes attribute values on the returned instance" do
            whizbang = @client.find(MySobjects::Whizbang, "23foo")
            response = JSON.parse(@response_body)
            MySobjects::Whizbang.description["fields"].collect { |f| [f["name"], f["label"]] }.each do |name, label|
              unless %w(Date_Field DateTime_Field Picklist_Multiselect_Field OtherDateTime_Field).include?(name)
                whizbang.send(name.to_sym).should == (response[label.gsub(' ', '_')] || response[name])
              end
            end
          end

          it "applies type coercions to the returned attributes" do
            object = @client.find(MySobjects::Whizbang, "23foo")
            object.Date_Field.should be_instance_of(Date)
            object.DateTime_Field.should be_instance_of(DateTime)
            object.Picklist_Multiselect_Field.should be_instance_of(Array)
          end

          it "parses Date attributes" do
            object = @client.find(MySobjects::Whizbang, "23foo")
            object.Date_Field.should == Date.civil(2010, 01, 01)
          end

          it "parses DateTime attributes" do
            object = @client.find(MySobjects::Whizbang, "23foo")
            object.DateTime_Field.should == DateTime.civil(2011, 07, 07, 0, 37, 0)
          end
        end

        context "with an invalid id" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/sobject_find_error_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/23foo").to_return(:body => @response_body, :status => 400)
          end

          it "raises Databasedotcom::SalesForceError" do
            lambda {
              @client.find(MySobjects::Whizbang, "23foo")
            }.should raise_error(Databasedotcom::SalesForceError)
          end
        end
      end

      describe "#query" do
        it "properly escapes query parameters" do
          response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_empty_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/query?q=SELECT+Name+FROM+Whizbang+WHERE+Name='steve%20%26%20me%3F'").to_return(:body => response_body, :status => 200)
          @client.query("SELECT Name FROM Whizbang WHERE Name='steve & me?'").should be_a_kind_of(Enumerable)
        end

        context "with results" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_success_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/query?q=SELECT+Checkbox_Label+FROM+Whizbang").to_return(:body => @response_body, :status => 200)
          end

          it "returns an enumerable result" do
            @client.query("SELECT Checkbox_Label FROM Whizbang").should be_a_kind_of(Enumerable)
          end

          it "returns an enumerable of materialized instances" do
            results = @client.query("SELECT Checkbox_Label FROM Whizbang")
            results.each do |result|
              result.should be_instance_of(MySobjects::Whizbang)
            end
          end

          it "fills in the attributes of the returned objects with the values returned from the query" do
            results = @client.query("SELECT Checkbox_Label FROM Whizbang")
            results.first.Checkbox_Field.should be_false
            results.first.Text_Field.should == "Hi there!"
          end

          it "applies type coercions to the returned attributes" do
            object = @client.query("SELECT Checkbox_Label FROM Whizbang").first
            object.Date_Field.should be_instance_of(Date)
            object.DateTime_Field.should be_instance_of(DateTime)
            object.Picklist_Multiselect_Field.should be_instance_of(Array)
          end

          it "traverses relationships" do
            object = @client.query("SELECT Checkbox_Label FROM Whizbang").first
            object.ParentWhizbang__r.should be_instance_of(MySobjects::Whizbang)
            object.ParentWhizbang__r.Text_Field.should == "Hello"
          end
        end

        context "with paginated results" do
          before do
            @first_page_response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_paginated_first_page_response.json"))
            @last_page_response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_paginated_last_page_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/query?q=SELECT+Text_Label+FROM+Whizbang").to_return(:body => @first_page_response_body, :status => 200)
            stub_request(:get, "https://na1.salesforce.com/next/page/url").to_return(:body => @last_page_response_body, :status => 200)
            @first_page_results = @client.query("SELECT Text_Label FROM Whizbang")
          end

          it "returns the first page of results" do
            @first_page_results.length.should == 1
            @first_page_results.total_size.should == 2
            @first_page_results.first.Text_Field.should == "First Page"
            @first_page_results.next_page?.should be_true
          end

          it "retrieves the next page of records when requested" do
            next_results = @first_page_results.next_page
            next_results.length.should == 1
            next_results.total_size.should == 2
            next_results.first.Text_Field.should == "Last Page"
            next_results.next_page?.should be_false
          end
        end

        context "with no results" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_empty_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/query?q=SELECT+Checkbox_Label+FROM+Whizbang+WHERE+Checkbox_Label=true").to_return(:body => @response_body, :status => 200)
          end

          it "returns an empty enumerable" do
            @client.query("SELECT Checkbox_Label FROM Whizbang WHERE Checkbox_Label=true").should be_empty
          end
        end

        context "with an error" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_error_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/query?q=SELECT+Checkbox_Label+FROM+Whizbang").to_return(:body => @response_body, :status => 400)
          end

          it "raises Databasedotcom::SalesForceError" do
            lambda {
              @client.query("SELECT Checkbox_Label FROM Whizbang")
            }.should raise_error(Databasedotcom::SalesForceError)
          end
        end
      end

      describe "collection operations" do
        before do
          @first_page_response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_paginated_first_page_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/query?q=SELECT+Checkbox_Label+FROM+Whizbang").to_return(:body => @first_page_response_body, :status => 200)
          @last_page_response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/query_paginated_last_page_response.json"))
          stub_request(:get, "https://na1.salesforce.com/next/page/url").to_return(:body => @last_page_response_body, :status => 200)
          @collection = @client.query("SELECT Checkbox_Label FROM Whizbang")
        end

        describe "#next_page" do
          it "requests the next page from the server" do
            @collection.next_page
            WebMock.should have_requested(:get, "https://na1.salesforce.com/next/page/url")
          end
        end

        describe "#previous_page" do
          it "returns an empty collection" do
            @collection.previous_page.total_size.should be_zero
          end
        end
      end

      describe "#create" do
        context "with proper fields" do
          context "with attributes from a JSON" do
            before do
              @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/create_success_response.json"))
              stub_request(:post, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang").to_return(:body => @response_body, :status => 201)
            end

            it "successfully creates a new object" do
              @client.create(MySobjects::Whizbang, "{\"Name\":\"foo\"}")
              WebMock.should have_requested(:post, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang")
            end

            it "returns an instantiated object of the specified class" do
              @client.create(MySobjects::Whizbang, "{\"Name\":\"foo\"}").should be_an_instance_of(MySobjects::Whizbang)
            end

            it "returns an instantiated object with the correct attributes specified by the JSON" do
              @client.create(MySobjects::Whizbang, "{\"Name\":\"foo\"}").Name.should == "foo"
            end

            it "fills in the Id on the returned object" do
              @client.create(MySobjects::Whizbang, "{\"Name\":\"foo\"}").Id.should_not be_nil
            end
          end

          context "with attributes from a hash" do
            before do
              @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/create_success_response.json"))
              stub_request(:post, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang").to_return(:body => @response_body, :status => 201)
            end

            it "successfully creates a new object" do
              @client.create(MySobjects::Whizbang, "Name" => "foo")
              WebMock.should have_requested(:post, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang")
            end

            it "returns an instantiated object of the specified class" do
              @client.create(MySobjects::Whizbang, "Name" => "foo").should be_an_instance_of(MySobjects::Whizbang)
            end

            it "returns an instantiated object with the correct attributes specified by the JSON" do
              @client.create(MySobjects::Whizbang, "Name" => "foo").Name.should == "foo"
            end

            it "applies type coercions before serializing" do
              @client.create(MySobjects::Whizbang, "Date_Field" => Date.civil(2011, 1, 1), "DateTime_Field" => DateTime.civil(2011, 2, 1, 12), "Picklist_Multiselect_Field" => %w(a b))
              WebMock.should have_requested(:post, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang").with(:body => {"Date_Field" => "2011-01-01", "DateTime_Field" => "2011-02-01T12:00:00.000+0000", "Picklist_Multiselect_Field" => "a;b"})
            end

            it "does not apply coercion to String value in a 'date' field" do
              @client.create(MySobjects::Whizbang, "Date_Field" => "2011-01-01")
              WebMock.should have_requested(:post, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang").with(:body => %|{"Date_Field":"2011-01-01"}|)
            end

            it "fills in the Id on the returned object" do
              @client.create(MySobjects::Whizbang, "Name" => "foo").Id.should_not be_nil
            end
          end
        end

        context "with improper fields" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/write_error_response.json"))
            stub_request(:post, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang").to_return(:body => @response_body, :status => 400)
          end

          it "raises an Databasedotcom::SalesForceError" do
            lambda {
              @client.create(MySobjects::Whizbang, "{\"Laugh\":\"hahaha\"}")
            }.should raise_error(Databasedotcom::SalesForceError)
          end
        end
      end

      describe "#update" do
        context "with proper fields" do
          context "with attributes from a JSON" do
            it "persists the updated changes" do
              stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => nil, :status => 204)
              @client.update("Whizbang", "rid", "{\"Name\":\"update\"}")
              WebMock.should have_requested(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid")
            end
          end

          context "with attributes from a hash" do
            it "persists the updated changes" do
              stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => nil, :status => 204)
              @client.update("Whizbang", "rid", {"Name" => "update"})
              WebMock.should have_requested(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid")
            end

            it "persists the updated changes with names as symbols" do
              stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => nil, :status => 204)
              @client.update("Whizbang", "rid", {:Name => "update"})
              WebMock.should have_requested(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid")
            end

            it "applies type coercions before serializing" do
              stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => nil, :status => 204)
              @client.update("Whizbang", "rid", "Date_Field" => Date.civil(2011, 1, 1), "DateTime_Field" => DateTime.civil(2011, 2, 1, 12), "Picklist_Multiselect_Field" => %w(a b))
              WebMock.should have_requested(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").with(:body => {"Date_Field" => "2011-01-01", "DateTime_Field" => "2011-02-01T12:00:00.000+0000", "Picklist_Multiselect_Field" => "a;b"})
            end

            it "applies type coercions with Dates represented as Strings" do
              stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => nil, :status => 204)
              @client.update("Whizbang", "rid", "Date_Field" => Date.civil(2011, 1, 1).to_s, "DateTime_Field" => DateTime.civil(2011, 2, 1, 12).to_s, "Picklist_Multiselect_Field" => %w(a b))
              WebMock.should have_requested(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").with(:body => {"Date_Field" => "2011-01-01", "DateTime_Field" => "2011-02-01T12:00:00.000+0000", "Picklist_Multiselect_Field" => "a;b"})
            end
          end
        end

        context "with improper fields" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/write_error_response.json"))
            stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => @response_body, :status => 400)
          end

          it "raises an Databasedotcom::SalesForceError" do
            lambda {
              @client.update("Whizbang", "rid", "{\"Namex\":\"update\"}")
            }.should raise_error(Databasedotcom::SalesForceError)
          end
        end
      end

      describe "#upsert" do
        context "with a valid external field" do
          context "with a non-existent external id" do
            it "creates a new record with the external id and the specified attributes" do
              @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/upsert_created_success_response.json"))
              stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/Name/somename").to_return(:body => @response_body, :status => 201)
              @client.upsert("Whizbang", "Name", "somename", "Name" => "newname")
              WebMock.should have_requested(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/Name/somename").with(:body => %|{"Name":"newname"}|)
            end
          end

          context "with an existing external id" do
            it "updates attributes in the existing object" do
              @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/upsert_updated_success_response.json"))
              stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/Name/somename").to_return(:body => @response_body, :status => 201)
              @client.upsert("Whizbang", "Name", "somename", "Name" => "newname")
              WebMock.should have_requested(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/Name/somename").with(:body => %|{"Name":"newname"}|)
            end
          end

          context "with multiple choice" do
            before do
              @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/upsert_multiple_error_response.json"))
              stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/Name/ambiguous").to_return(:body => @response_body, :status => 300)
            end

            it "raises an Databasedotcom::SalesForceError" do
              lambda {
                @client.upsert("Whizbang", "Name", "ambiguous", "Name" => "newname")
              }.should raise_error(Databasedotcom::SalesForceError)
            end
          end
        end

        context "with an invalid external field" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/upsert_error_response.json"))
            stub_request(:patch, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/Namez/fakename").to_return(:body => @response_body, :status => 404)
          end

          it "raises an Databasedotcom::SalesForceError" do
            lambda {
              @client.upsert("Whizbang", "Namez", "fakename", "{\"Name\":\"update\"}")
            }.should raise_error(Databasedotcom::SalesForceError)
          end
        end
      end

      describe "#delete" do
        context "with proper record ID" do
          it "destroys the specified record" do
            stub_request(:delete, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => nil, :status => 204)
            @client.delete("Whizbang", "rid")
            WebMock.should have_requested(:delete, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid")
          end

          it "can take a Class as the first argument" do
            stub_request(:delete, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => nil, :status => 204)
            @client.delete(MySobjects::Whizbang, "rid")
            WebMock.should have_requested(:delete, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid")
          end
        end

        context "with non-existent record ID" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/delete_error_response.json"))
            stub_request(:delete, "https://na1.salesforce.com/services/data/v23.0/sobjects/Whizbang/rid").to_return(:body => @response_body, :status => 404)
          end

          it "raises an Databasedotcom::SalesForceError" do
            lambda {
              @client.delete("Whizbang", "rid")
            }.should raise_error(Databasedotcom::SalesForceError)
          end
        end
      end

      describe "#search" do
        context "with a well-formed query" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/search_success_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/search?q=foo").to_return(:body => @response_body, :status => 200)
          end

          it "executes a search and calls .find for each of the search results" do
            @client.should_receive(:find).with("Whizbang", "foo").and_return(MySobjects::Whizbang.new)
            @client.should_receive(:find).with("Whizbang", "bar").and_return(MySobjects::Whizbang.new)
            results = @client.search("foo")
            results.should be_instance_of(Databasedotcom::Collection)
            results.next_page?.should be_false
            WebMock.should have_requested(:get, "https://na1.salesforce.com/services/data/v23.0/search?q=foo")
          end
        end

        context "with an error" do
          before do
            @response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/search_error_response.json"))
            stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/search?q=foo").to_return(:body => @response_body, :status => 400)
          end

          it "raises Databasedotcom::SalesForceError" do
            lambda {
              @client.search("foo")
            }.should raise_error(Databasedotcom::SalesForceError)
          end
        end
      end

      describe "#recent" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/sobject/recent_success_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/recent").to_return(:body => response_body, :status => 200)
        end

        it "requests the recently-touched objects and calls .find on them" do
          @client.should_receive(:find).with("Whizbang", "foo").and_return(MySobjects::Whizbang.new)
          @client.should_receive(:find).with("Whizbang", "bar").and_return(MySobjects::Whizbang.new)
          @client.recent
          WebMock.should have_requested(:get, "https://na1.salesforce.com/services/data/v23.0/recent")
        end
      end

      describe "#trending_topics" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), "../fixtures/chatter/trending_topics_get_success_response.json"))
          stub_request(:get, "https://na1.salesforce.com/services/data/v23.0/chatter/topics/trending").to_return(:body => response_body, :status => 200)
        end

        it "returns the trending topics" do
          @client.trending_topics.should == %w(dude)
          WebMock.should have_requested(:get, "https://na1.salesforce.com/services/data/v23.0/chatter/topics/trending")
        end
      end
    end

    describe "#http_get" do
      it "gets the requested path" do
        stub_request(:get, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 200)
        @client.http_get("/my/path")
        WebMock.should have_requested(:get, "https://na1.salesforce.com/my/path")
      end

      it "puts parameters into the path" do
        stub_request(:get, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap").to_return(:body => "", :status => 200)
        @client.http_get("/my/path", :foo => "bar", "bro" => "baz bap")
        WebMock.should have_requested(:get, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap")
      end

      it "includes the headers in the request" do
        stub_request(:get, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 200)
        @client.http_get("/my/path", nil, {"Something" => "Header"})
        WebMock.should have_requested(:get, "https://na1.salesforce.com/my/path").with(:headers => {"Something" => "Header"})
      end

      it "raises SalesForceError" do
        stub_request(:get, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 400)
        lambda {
          @client.http_get("/my/path", nil, {"Something" => "Header"})
        }.should raise_error(Databasedotcom::SalesForceError)
      end

      it_should_behave_like "a request that can refresh the oauth token", :get, "get", "https://na1.salesforce.com/my/path", 200
    end

    describe "#http_delete" do
      it "makes a delete request with the specified path" do
        stub_request(:delete, "https://na1.salesforce.com/delete/this/rid").to_return(:body => nil, :status => 204)
        @client.http_delete("/delete/this/rid")
        WebMock.should have_requested(:delete, "https://na1.salesforce.com/delete/this/rid")
      end

      it "puts parameters into the path" do
        stub_request(:delete, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap").to_return(:body => "", :status => 204)
        @client.http_delete("/my/path", :foo => "bar", "bro" => "baz bap")
        WebMock.should have_requested(:delete, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap")
      end

      it "includes the headers in the request" do
        stub_request(:delete, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 204)
        @client.http_delete("/my/path", {}, {"Something" => "Header"})
        WebMock.should have_requested(:delete, "https://na1.salesforce.com/my/path").with(:headers => {"Something" => "Header"})
      end

      it "raises SalesForceError" do
        stub_request(:delete, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 400)
        lambda {
          @client.http_delete("/my/path")
        }.should raise_error(Databasedotcom::SalesForceError)
      end

      it_should_behave_like "a request that can refresh the oauth token", :delete, "delete", "https://na1.salesforce.com/my/path", 204
    end

    describe "#http_post" do
      it "posts the data to the specified path" do
        stub_request(:post, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 201)
        @client.http_post("/my/path", "data")
        WebMock.should have_requested(:post, "https://na1.salesforce.com/my/path").with(:body => "data")
      end

      it "puts parameters into the path" do
        stub_request(:post, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap").to_return(:body => "", :status => 201)
        @client.http_post("/my/path", "data", :foo => "bar", "bro" => "baz bap")
        WebMock.should have_requested(:post, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap")
      end

      it "includes the headers in the request" do
        stub_request(:post, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 201)
        @client.http_post("/my/path", "data", nil, {"Something" => "Header"})
        WebMock.should have_requested(:post, "https://na1.salesforce.com/my/path").with(:headers => {"Something" => "Header"})
      end

      it "raises SalesForceError" do
        stub_request(:post, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 400)
        lambda {
          @client.http_post("/my/path", "data", nil, {"Something" => "Header"})
        }.should raise_error(Databasedotcom::SalesForceError)
      end

      it_should_behave_like "a request that can refresh the oauth token", :post, "post", "https://na1.salesforce.com/my/path", 201
    end

    describe "#http_multipart_post" do
      it "posts multipart data to the specified path" do
        stub_request(:post, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 201)
        @client.http_multipart_post("/my/path", :foo => "bar")
        WebMock.should have_requested(:post, "https://na1.salesforce.com/my/path").with(:headers => {"Content-Type" => "multipart/form-data; boundary=-----------RubyMultipartPost"})
      end

      it "puts parameters into the path" do
        stub_request(:post, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap").to_return(:body => "", :status => 201)
        @client.http_multipart_post("/my/path", {}, :foo => "bar", "bro" => "baz bap")
        WebMock.should have_requested(:post, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap")
      end

      it "includes the headers in the request" do
        stub_request(:post, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 201)
        @client.http_multipart_post("/my/path", {}, {}, {"Something" => "Header"})
        WebMock.should have_requested(:post, "https://na1.salesforce.com/my/path").with(:headers => {"Something" => "Header"})
      end

      it "raises SalesForceError" do
        stub_request(:post, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 400)
        lambda {
          @client.http_multipart_post("/my/path", {}, {}, {"Something" => "Header"})
        }.should raise_error(Databasedotcom::SalesForceError)
      end

      it_should_behave_like "a request that can refresh the oauth token", :post, "multipart_post", "https://na1.salesforce.com/my/path", 201
    end

    describe "#http_patch" do
      it "upserts the data to the specified path" do
        stub_request(:patch, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 201)
        @client.http_patch("/my/path", "data")
        WebMock.should have_requested(:patch, "https://na1.salesforce.com/my/path").with(:body => "data")
      end

      it "puts parameters into the path" do
        stub_request(:patch, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap").to_return(:body => "", :status => 201)
        @client.http_patch("/my/path", "data", :foo => "bar", "bro" => "baz bap")
        WebMock.should have_requested(:patch, "https://na1.salesforce.com/my/path?foo=bar&bro=baz%20bap")
      end

      it "includes the headers in the request" do
        stub_request(:patch, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 201)
        @client.http_patch("/my/path", "data", nil, {"Something" => "Header"})
        WebMock.should have_requested(:patch, "https://na1.salesforce.com/my/path").with(:headers => {"Something" => "Header"})
      end

      it "raises SalesForceError" do
        stub_request(:patch, "https://na1.salesforce.com/my/path").to_return(:body => "", :status => 400)
        lambda {
          @client.http_patch("/my/path", "data", nil, {"Something" => "Header"})
        }.should raise_error(Databasedotcom::SalesForceError)
      end
    end
  end
end
