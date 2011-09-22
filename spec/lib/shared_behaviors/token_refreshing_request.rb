shared_examples_for("a request that can refresh the oauth token") do |request_method, request_method_name, request_url, success_status_code|
  describe "when receiving a 401 response" do
    before do
      stub_request(request_method, request_url).to_return(:body => "", :status => 401).then.to_return(:body => "", :status => success_status_code)
    end
    
    context "with a refresh token" do
      before do
        @client.refresh_token = "refresh"
      end
      
      after do
        @client.refresh_token = nil
      end
      
      context "when the refresh token flow succeeds" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), "../../fixtures/refresh_success_response.json"))
          stub_request(:post, "https://bro.baz/services/oauth2/token?client_id=client_id&client_secret=client_secret&grant_type=refresh_token&refresh_token=refresh").to_return(:body => response_body, :status => 200)
        end
        
        it "stores the new access token" do
          @client.send("http_#{request_method_name}", URI.parse(request_url).path, {})
          @client.oauth_token.should == "refreshed_access_token"
        end
        
        it "retries the request" do
          @client.send("http_#{request_method_name}", URI.parse(request_url).path, {})
          WebMock.should have_requested(request_method, request_url).twice
        end
      end
      
      context "when the refresh token flow fails" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), "../../fixtures/refresh_error_response.json"))
          stub_request(:post, "https://bro.baz/services/oauth2/token?client_id=client_id&client_secret=client_secret&grant_type=refresh_token&refresh_token=refresh").to_return(:body => response_body, :status => 400)
        end
        
        it "raises SalesForceError" do
          lambda {
            @client.send("http_#{request_method_name}", URI.parse(request_url).path, {})
          }.should raise_error(Databasedotcom::SalesForceError)
        end
      end
    end
    
    context "with a username and password" do
      before do
        @client.username = "username"
        @client.password = "password"
      end
      
      after do
        @client.username = @client.password = nil
      end
      
      context "when reauthentication succeeds" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), "../../fixtures/reauth_success_response.json"))
          stub_request(:post, "https://bro.baz/services/oauth2/token?client_id=client_id&client_secret=client_secret&grant_type=password&username=username&password=password").to_return(:body => response_body, :status => 200)
        end
        
        it "stores the new access token" do
          @client.send("http_#{request_method_name}", URI.parse(request_url).path, {})
          @client.oauth_token.should == "new_access_token"
        end
        
        it "retries the request" do
          @client.send("http_#{request_method_name}", URI.parse(request_url).path, {})
          WebMock.should have_requested(request_method, request_url).twice
        end
      end
      
      context "when reauthentication fails" do
        before do
          response_body = File.read(File.join(File.dirname(__FILE__), "../../fixtures/auth_error_response.json"))
          stub_request(:post, "https://bro.baz/services/oauth2/token?client_id=client_id&client_secret=client_secret&grant_type=password&username=username&password=password").to_return(:body => response_body, :status => 400)
        end
        
        it "raises SalesForceError" do
          lambda {
            @client.send("http_#{request_method_name}", URI.parse(request_url).path, {})
          }.should raise_error(Databasedotcom::SalesForceError)
        end
      end
    end
    
    context "without a refresh token or username/password" do
      it "raises SalesForceError" do
        lambda {
          @client.send("http_#{request_method_name}", URI.parse(request_url).path, {})
        }.should raise_error(Databasedotcom::SalesForceError)
      end
    end
  end
end
