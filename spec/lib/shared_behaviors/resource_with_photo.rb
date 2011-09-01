shared_examples_for("a resource with a photo") do
  describe ".photo" do
    before do
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_photo_get_id_success_response.json")))
      @client_mock = double("client", :version => "23")
    end

    it "returns a hash containing photo info" do
      @client_mock.should_receive(:http_get).with("/services/data/v23/chatter/#{described_class.resource_name}/foo/photo").and_return(@response)
      photo = described_class.photo(@client_mock, "foo")
      photo.should be_instance_of(Hash)
    end
  end

  describe ".upload_photo" do
    before do
      @response = double("response", :body => File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_photo_get_id_success_response.json")))
      @client_mock = double("client", :version => "23")
    end

    it "uploads the photo and returns a hash containing photo info" do
      @client_mock.should_receive(:http_multipart_post).with("/services/data/v23/chatter/#{described_class.resource_name}/foo/photo", an_instance_of(Hash)).and_return(@response)
      file_mock = double("file", :read => "foo", :path => "filename")
      photo = described_class.upload_photo(@client_mock, "foo", file_mock, "image/gif")
      photo.should be_instance_of(Hash)
    end
  end

  describe ".delete_photo" do
    before do
      @client_mock = double("client", :version => "23")
    end

    it "deletes the photo of the specified user" do
      @client_mock.should_receive(:http_delete).with("/services/data/v23/chatter/#{described_class.resource_name}/foo/photo").and_return(true)
      described_class.delete_photo(@client_mock, "foo")
    end
  end

  context "with an instantiated object" do
    before do
      @response = File.read(File.join(File.dirname(__FILE__), "../../fixtures/chatter/#{described_class.resource_name}_get_id_success_response.json"))
      @client_mock = double("client", :version => "23")
      @resource = described_class.new(@client_mock, @response)
    end

    describe "#photo" do
      it "returns a hash with the resource's photo" do
        @resource.photo.should == @resource.raw_hash["photo"]
      end
    end

    describe "#upload_photo" do
      it "uploads a photo for the resource" do
        described_class.should_receive(:upload_photo).with(@client_mock, @resource.id, "io", "image/gif")
        @resource.upload_photo("io", "image/gif")
      end
    end

    describe "#delete_photo" do
      it "deletes the resource's current photo" do
        @client_mock.should_receive(:http_delete).with("/services/data/v23/chatter/#{described_class.resource_name}/#{@resource.id}/photo").and_return(true)
        @resource.delete_photo
      end
    end
  end
end
