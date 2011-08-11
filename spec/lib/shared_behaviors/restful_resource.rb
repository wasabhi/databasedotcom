shared_examples_for("a restful resource") do
  describe "#initialize" do
    describe "from a JSON response" do
      before do
        @response = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_get_id_success_response.json"))
        @client_mock = double("client")
        @record = described_class.new(@client_mock, @response)
      end

      it "is a Record" do
        @record.should be_a_kind_of(Databasedotcom::Chatter::Record)
      end
    end
  end

  describe ".find" do
    context "with a single id" do
      before do
        body = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_get_id_success_response.json"))
        @client_mock = double("client", :version => "23")
        @response = double("response")
        @response.should_receive(:body).any_number_of_times.and_return(body)
      end

      it "gets a resource by id" do
        @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/#{described_class.resource_name}/rid", {}).and_return(@response)
        resource = described_class.find(@client_mock, "rid")
        resource.should be_instance_of(described_class)
      end

      it "passes through parameters" do
        @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/#{described_class.resource_name}/rid", {:page => "foo", :pageSize => 10}).and_return(@response)
        described_class.find(@client_mock, "rid", :page => "foo", :pageSize => 10)
      end

      context "with a parent user id" do
        it "constructs the path appropriately" do
          @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/me/#{described_class.resource_name}/rid", {:page => "foo", :pageSize => 10}).and_return(@response)
          described_class.find(@client_mock, "rid", :page => "foo", :pageSize => 10, :user_id => "me")
        end
      end
    end

    if File.exists?(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_batch_get_success_response.json"))
      context "with an array of ids" do
        context "when all the ids are valid" do
          before do
            body = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_batch_get_success_response.json"))
            @client_mock = double("client", :version => "23")
            @response = double("response")
            @response.should_receive(:body).any_number_of_times.and_return(body)
          end

          it "gets all the resources" do
            @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/#{described_class.resource_name}/batch/fid,gid", {}).and_return(@response)
            resources = described_class.find(@client_mock, %w(fid gid))
            resources.should be_instance_of(Databasedotcom::Collection)
            resources.each do |resource|
              resource.should be_instance_of(described_class)
            end
          end
        end

        context "when some of the ids are not valid" do
          before do
            body = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_batch_get_mixed_response.json"))
            @client_mock = double("client", :version => "23")
            @response = double("response")
            @response.should_receive(:body).any_number_of_times.and_return(body)
          end

          it "gets all the users" do
            @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/#{described_class.resource_name}/batch/fid,gid", {}).and_return(@response)
            resources = described_class.find(@client_mock, %w(fid gid))
            resources.should be_instance_of(Databasedotcom::Collection)
            resources.length.should == 1
          end
        end
      end
    end
  end

  if File.exists?(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_get_success_response.json"))
    describe ".all" do
      before do
        body = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_get_success_response.json"))
        @client_mock = double("client", :version => "23")
        @response = double("response")
        @response.should_receive(:body).any_number_of_times.and_return(body)
      end

      it "gets a collection of resources" do
        @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/#{described_class.resource_name}", {}).and_return(@response)
        resources = described_class.all(@client_mock)
        resources.should be_instance_of(Databasedotcom::Collection)
        resources.each do |resource|
          resource.should be_instance_of(described_class)
        end
      end

      it "passes through parameters" do
        @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/#{described_class.resource_name}", {:page => "foo", :pageSize => 10}).and_return(@response)
        described_class.all(@client_mock, :page => "foo", :pageSize => 10)
      end

      context "with a parent user id" do
        it "constructs the path appropriately" do
          @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/users/me/#{described_class.resource_name}", {:page => "foo", :pageSize => 10}).and_return(@response)
          described_class.all(@client_mock, :page => "foo", :pageSize => 10, :user_id => "me")
        end
      end
    end
  end

  describe ".search" do
    it "calls .find with the appropriate parameters" do
      described_class.should_receive(:all).with("client", {:foo => "bar", described_class.search_parameter_name => "query"})
      described_class.search("client", "query", {:foo => "bar"})
    end
  end

  describe ".delete" do
    before do
      @client_mock = double("client", :version => "23")
    end

    it "deletes the resource specified by id" do
      @client_mock.should_receive(:http_delete).with("/services/data/v23/chatter/#{described_class.resource_name}/rid", {}).and_return(true)
      described_class.delete(@client_mock, "rid")
    end

    context "with a parent user id" do
      it "constructs the path appropriately" do
        @client_mock.should_receive(:http_delete).with("/services/data/v23/chatter/users/me/#{described_class.resource_name}/rid", {}).and_return(@response)
        described_class.delete(@client_mock, "rid", :user_id => "me")
      end
    end
  end
end