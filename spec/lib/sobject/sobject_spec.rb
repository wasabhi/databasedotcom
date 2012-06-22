require 'rspec'
require 'spec_helper'
require 'databasedotcom'

describe Databasedotcom::Sobject::Sobject do
  class TestClass < Databasedotcom::Sobject::Sobject
  end

  before do
    @client = Databasedotcom::Client.new(File.join(File.dirname(__FILE__), "../../fixtures/databasedotcom.yml"))
    @client.authenticate(:token => "foo", :instance_url => "https://na9.salesforce.com")
    TestClass.client = @client
  end

  describe "materialization" do
    context "with a valid Sobject name" do
      response = JSON.parse(File.read(File.join(File.dirname(__FILE__), "../../fixtures/sobject/sobject_describe_success_response.json")))

      it "requests a description of the class" do
        @client.should_receive(:describe_sobject).with("TestClass").and_return(response)
        TestClass.materialize("TestClass")
      end

      context "with a response" do
        before do
          @client.stub(:describe_sobject).and_return(response)
          TestClass.materialize("TestClass")
          @sobject = TestClass.new
        end

        describe ".attributes" do
          it "returns the attributes for this Sobject" do
            TestClass.attributes.should_not be_nil
            TestClass.attributes.should =~ response["fields"].collect { |f| [f["name"], f["relationshipName"]] }.flatten.compact
          end
        end

        describe "getters and setters" do
          response["fields"].collect { |f| f["name"] }.each do |name|
            it "creates a getter and setter for the #{name} attribute" do
              @sobject.should respond_to(name.to_sym)
              @sobject.should respond_to("#{name}=".to_sym)
            end
          end
        end

        describe "default values" do
          response["fields"].each do |f|
            if f['type'] =~ /(picklist|multipicklist)/ && picklist_option = f['picklistValues'].find { |p| p['defaultValue'] }
              it "sets #{f['name']} to #{picklist_option['value']}" do
                @sobject.send(f['name'].to_sym).should == picklist_option['value']
              end
            elsif f['type'] =~ /boolean/
              it "sets #{f['name']} to #{f['defaultValue']}" do
                @sobject.send(f['name'].to_sym).should == f['defaultValue']
              end
            else
              it "sets #{f['name']} to #{f['defaultValueFormula'] ? f['defaultValueFormula'] : 'nil'}" do
                @sobject.send(f["name"].to_sym).should == f["defaultValueFormula"]
              end
            end
          end
        end
      end
    end

    context "with an invalid Sobject name" do
      it "propagates exceptions" do
        @client.should_receive(:describe_sobject).with("TestClass").and_raise(Databasedotcom::SalesForceError.new(double("result", :body => "{}")))
        lambda {
          TestClass.materialize("TestClass")
        }.should raise_error(Databasedotcom::SalesForceError)
      end
    end
  end

  context "with a materialized class" do
    before do
      response = JSON.parse(File.read(File.join(File.dirname(__FILE__), "../../fixtures/sobject/sobject_describe_success_response.json")))
      @client.should_receive(:describe_sobject).with("TestClass").and_return(response)
      TestClass.materialize("TestClass")
      @field_names = TestClass.description["fields"].collect { |f| f["name"] }
    end

    describe "#==" do

      before do
        @first = TestClass.new("Id" => "foo")
      end

      context "when the objects are the same class" do

        context "when the ids match" do

          before do
            @second = TestClass.new("Id" => "foo")
          end

          it "returns true" do
            @first.should == @second
          end
        end

        context "when the ids do not match" do

          before do
            @second = TestClass.new("Id" => "bar")
          end

          it "returns false" do
            @first.should_not == @second
          end
        end
      end

      context "when the objects are different classes" do

        before do
          @second = stub(:is_a? => false)
        end

        it "returns false" do
          @first.should_not == @second
        end
      end
    end

    describe ".new" do
      it "creates a new in-memory instance with the specified attributes" do
        obj = TestClass.new("Name" => "foo")
        obj.Name.should == "foo"
        obj.should be_new_record
      end
    end

    describe ".create" do
      it "returns a new instance with the specified attributes" do
        @client.should_receive(:create).with(TestClass, "moo").and_return("gar")
        TestClass.create("moo").should == "gar"
      end
    end

    describe ".find" do
      context "with a valid id" do
        it "returns the found instance" do
          @client.should_receive(:find).with(TestClass, "abc").and_return("bar")
          TestClass.find("abc").should == "bar"
        end
      end

      context "with an invalid id" do
        it "propagates exceptions" do
          @client.should_receive(:find).with(TestClass, "abc").and_raise(Databasedotcom::SalesForceError.new(double("result", :body => "{}")))
          lambda {
            TestClass.find("abc")
          }.should raise_error(Databasedotcom::SalesForceError)
        end
      end
    end

    describe ".all" do
      it "returns a paginated enumerable containing all instances" do
        @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass").and_return("foo")
        TestClass.all.should == "foo"
      end
    end

    describe ".query" do
      it "constructs and submits a SOQL query" do
        @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'foo'").and_return("bar")
        TestClass.query("Name = 'foo'").should == "bar"
      end
    end

    describe ".delete" do
      it "deletes a record specified by id" do
        @client.should_receive(:delete).with("TestClass", "recordId").and_return("deleteResponse")
        TestClass.delete("recordId").should == "deleteResponse"
      end
    end

    describe ".first" do
      it "loads the first record" do
        @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass ORDER BY Id ASC LIMIT 1").and_return(["foo"])
        TestClass.first.should == "foo"
      end

      it "optionally includes SOQL conditions" do
        @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE conditions ORDER BY Id ASC LIMIT 1").and_return(["foo"])
        TestClass.first("conditions").should == "foo"
      end
    end

    describe ".last" do
      it "loads the last record" do
        @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass ORDER BY Id DESC LIMIT 1").and_return(["bar"])
        TestClass.last.should == "bar"
      end

      it "optionally includes SOQL conditions" do
        @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE conditions ORDER BY Id DESC LIMIT 1").and_return(["bar"])
        TestClass.last("conditions").should == "bar"
      end
    end

    describe ".count" do
      it "gets the record count" do
        @client.should_receive(:query).with("SELECT COUNT() FROM TestClass").and_return(double("collection", :total_size => 42))
        TestClass.count.should == 42
      end
    end

    describe ".coerce_params" do
      it "coerces boolean attributes" do
        TestClass.coerce_params("Checkbox_Field" => "1")["Checkbox_Field"].should be_true
        TestClass.coerce_params("Checkbox_Field" => "0")["Checkbox_Field"].should be_false
        TestClass.coerce_params("Checkbox_Field" => true)["Checkbox_Field"].should be_true
        TestClass.coerce_params("Checkbox_Field" => false)["Checkbox_Field"].should be_false
      end

      it "coerces currency attributes" do
        TestClass.coerce_params("Currency_Field" => "123.4")["Currency_Field"].should == 123.4
        TestClass.coerce_params("Currency_Field" => 123.4)["Currency_Field"].should == 123.4
        TestClass.coerce_params("Currency_Field" => "$123.4")["Currency_Field"].should == 123.4
      end

      it "coerces percent attributes" do
        TestClass.coerce_params("Percent_Field" => "123.4")["Percent_Field"].should == 123.4
        TestClass.coerce_params("Percent_Field" => 123.4)["Percent_Field"].should == 123.4
        TestClass.coerce_params("Percent_Field" => "123.4%")["Percent_Field"].should == 123.4
      end

      it "coerces date fields" do
        today = Date.today
        Date.stub(:today).and_return(today)
        TestClass.coerce_params("Date_Field" => "2010-04-01")["Date_Field"].should == Date.civil(2010, 4, 1)
        TestClass.coerce_params("Date_Field" => "bogus")["Date_Field"].should == Date.today
      end

      it "coerces datetime fields" do
        now = DateTime.now
        DateTime.stub(:now).and_return(now)
        TestClass.coerce_params("DateTime_Field" => "2010-04-01T12:05:10Z")["DateTime_Field"].to_s.should == DateTime.civil(2010, 4, 1, 12, 5, 10).to_s
        TestClass.coerce_params("DateTime_Field" => "bogus")["DateTime_Field"].to_s.should == now.to_s
      end

    end

    describe "dynamic finders" do
      describe "find_by_xxx" do
        context "with a single attribute" do
          it "constructs and executes a query matching the dynamic attributes" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'Richard' LIMIT 1").and_return(["bar"])
            TestClass.find_by_Name('Richard').should == "bar"
          end

          it "handles boolean values" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE IsDeleted = false LIMIT 1").and_return(["bar"])
            TestClass.find_by_IsDeleted(false).should == "bar"
          end

          it "handles numeric values" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Number_Field = 23.4 LIMIT 1").and_return(["bar"])
            TestClass.find_by_Number_Field(23.4).should == "bar"
          end

          it "handles date values" do
            today = Date.civil(2011, 04, 02)
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Date_Field = 2011-04-02 LIMIT 1").and_return(["bar"])
            TestClass.find_by_Date_Field(today).should == "bar"
          end

          it "handles datetime values" do
            now = DateTime.civil(2011, 04, 02, 20, 15, 33)
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE DateTime_Field = 2011-04-02T20:15:33.000+00:00 LIMIT 1").and_return(["bar"])
            TestClass.find_by_DateTime_Field(now).should == "bar"
          end

          it "handles time values" do
            now = Time.utc(2011, "apr", 2, 20, 15, 33)
            offs = now.utc.strftime("%z").insert(-3, ":")
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Time_Field = 2011-04-02T20:15:33.000#{offs} LIMIT 1").and_return(["bar"])
            TestClass.find_by_Time_Field(now).should == "bar"
          end

          it "escapes special characters" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'o\\'reilly' LIMIT 1").and_return(["bar"])
            TestClass.find_by_Name("o'reilly").should == "bar"
          end
        end

        context "with multiple attributes" do
          it "constructs and executes a query matching the dynamic attributes" do
            @client.should_receive(:query) do |query|
              query.should include("Name = 'Richard'")
              query.should include("City = 'San Francisco'")
              query.should include(" LIMIT 1")
              ["bar"]
            end
            TestClass.find_by_Name_and_City('Richard', 'San Francisco').should == "bar"
          end
        end
      end

      describe "find_all_by_xxx" do
        context "with a single attribute" do
          it "constructs and executes a query matching the dynamic attributes" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'Richard'").and_return(["bar"])
            TestClass.find_all_by_Name('Richard').should == ["bar"]
          end

          it "handles boolean values" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE IsDeleted = false").and_return(["bar"])
            TestClass.find_all_by_IsDeleted(false).should == ["bar"]
          end

          it "handles numeric values" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Number_Field = 23.4").and_return(["bar"])
            TestClass.find_all_by_Number_Field(23.4).should == ["bar"]
          end

          it "handles date values" do
            today = Date.civil(2011, 04, 02)
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Date_Field = 2011-04-02").and_return(["bar"])
            TestClass.find_all_by_Date_Field(today).should == ["bar"]
          end

          it "handles datetime values" do
            now = DateTime.civil(2011, 04, 02, 20, 15, 33)
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE DateTime_Field = 2011-04-02T20:15:33.000+00:00").and_return(["bar"])
            TestClass.find_all_by_DateTime_Field(now).should == ["bar"]
          end

          it "handles time values" do
            now = Time.utc(2011, "apr", 2, 20, 15, 33)
            offs = now.utc.strftime("%z").insert(-3, ":")
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Time_Field = 2011-04-02T20:15:33.000#{offs}").and_return(["bar"])
            TestClass.find_all_by_Time_Field(now).should == ["bar"]
          end

          it "escapes special characters" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'o\\'reilly'").and_return(["bar"])
            TestClass.find_all_by_Name("o'reilly").should == ["bar"]
          end
        end

        context "with multiple attributes" do
          it "constructs and executes a query matching the dynamic attributes" do
            @client.should_receive(:query) do |query|
              query.should include("Name = 'Richard'")
              query.should include("City = 'San Francisco'")
              ["bar"]
            end
            TestClass.find_all_by_Name_and_City('Richard', 'San Francisco').should == ["bar"]
          end
        end
      end
    end

    describe "dynamic creators" do
      describe "find_or_create_by_xxx" do
        context "with a single attribute" do
          it "searches for a record with the specified attribute and creates it if it doesn't exist" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'Richard' LIMIT 1").and_return(nil)
            @client.should_receive(:create).with(TestClass, "Name" => "Richard").and_return("gar")
            TestClass.find_or_create_by_Name('Richard').should == "gar"
          end

          it "handles boolean values" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE IsDeleted = false LIMIT 1").and_return(nil)
            @client.should_receive(:create).with(TestClass, "IsDeleted" => false).and_return("gar")
            TestClass.find_or_create_by_IsDeleted(false).should == "gar"
          end

          it "handles numeric values" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Number_Field = 23.4 LIMIT 1").and_return(nil)
            @client.should_receive(:create).with(TestClass, "Number_Field" => 23.4).and_return("gar")
            TestClass.find_or_create_by_Number_Field(23.4).should == "gar"
          end

          it "handles date values" do
            today = Date.civil(2011, 04, 02)
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Date_Field = 2011-04-02 LIMIT 1").and_return(nil)
            @client.should_receive(:create).with(TestClass, "Date_Field" => today).and_return("gar")
            TestClass.find_or_create_by_Date_Field(today).should == "gar"
          end

          it "handles datetime values" do
            now = DateTime.civil(2011, 04, 02, 20, 15, 33)
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE DateTime_Field = 2011-04-02T20:15:33.000+00:00 LIMIT 1").and_return(nil)
            @client.should_receive(:create).with(TestClass, "DateTime_Field" => now).and_return("gar")
            TestClass.find_or_create_by_DateTime_Field(now).should == "gar"
          end

          it "handles time values" do
            now = Time.utc(2011, "apr", 2, 20, 15, 33)
            offs = now.utc.strftime("%z").insert(-3, ":")
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Time_Field = 2011-04-02T20:15:33.000#{offs} LIMIT 1").and_return(nil)
            @client.should_receive(:create).with(TestClass, "Time_Field" => now).and_return("gar")
            TestClass.find_or_create_by_Time_Field(now).should == "gar"
          end

          it "escapes special characters" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'o\\'reilly' LIMIT 1").and_return(nil)
            @client.should_receive(:create).with(TestClass, "Name" => "o'reilly").and_return("gar")
            TestClass.find_or_create_by_Name("o'reilly").should == "gar"
          end
        end

        context "with multiple attributes" do
          it "searches for a record with the specified attributes and creates it if it doesn't exist" do
            @client.should_receive(:query) do |query|
              query.should include("Name = 'Richard'")
              query.should include("City = 'San Francisco'")
              query.should include(" LIMIT 1")
              nil
            end
            @client.should_receive(:create).with(TestClass, {"Name" => "Richard", "City" => "San Francisco"}).and_return("bar")
            TestClass.find_or_create_by_Name_and_City('Richard', 'San Francisco').should == "bar"
          end
        end

        context "with a hash argument containing additional attributes" do
          it "finds by the named arguments, but creates by all values in the hash" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'Richard' LIMIT 1").and_return(nil)
            @client.should_receive(:create).with(TestClass, "Name" => "Richard", "Email_Field" => "foo@bar.com", "IsDeleted" => false).and_return("gar")
            TestClass.find_or_create_by_Name("Name" => 'Richard', "Email_Field" => "foo@bar.com", "IsDeleted" => false).should == "gar"
          end
        end
      end
    end

    describe "dynamic initializers" do
      describe "find_or_initialize_by_xxx" do
        context "with a single attribute" do
          it "searches for a record with the specified attribute and initializes it if it doesn't exist" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'Richard' LIMIT 1").and_return(nil)
            TestClass.find_or_initialize_by_Name('Richard').Name.should == "Richard"
          end

          it "handles boolean values" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE IsDeleted = false LIMIT 1").and_return(nil)
            TestClass.find_or_initialize_by_IsDeleted(false).IsDeleted.should be_false
          end

          it "handles numeric values" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Number_Field = 23.4 LIMIT 1").and_return(nil)
            TestClass.find_or_initialize_by_Number_Field(23.4).Number_Field.should == 23.4
          end

          it "handles date values" do
            today = Date.civil(2011, 11, 28)
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Date_Field = 2011-11-28 LIMIT 1").and_return(nil)
            TestClass.find_or_initialize_by_Date_Field(today).Date_Field.should == today
          end

          it "handles datetime values" do
            now = DateTime.civil(2011, 04, 02, 20, 15, 33)
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE DateTime_Field = 2011-04-02T20:15:33.000+00:00 LIMIT 1").and_return(nil)
            TestClass.find_or_initialize_by_DateTime_Field(now).DateTime_Field.should == now
          end

          it "handles time values" do
            now = Time.utc(2011, "apr", 2, 20, 15, 33)
            offs = now.utc.strftime("%z").insert(-3, ":")
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE DateTime_Field = 2011-04-02T20:15:33.000#{offs} LIMIT 1").and_return(nil)
            TestClass.find_or_initialize_by_DateTime_Field(now).DateTime_Field.should == now
          end

          it "escapes special characters" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'o\\'reilly' LIMIT 1").and_return(nil)
            TestClass.find_or_initialize_by_Name("o'reilly").Name.should == "o'reilly"
          end
        end

        context "with multiple attributes" do
          it "searches for a record with the specified attributes and initializes it if it doesn't exist" do
            @client.should_receive(:query) do |select_statement|
              select_statement.index("SELECT #{@field_names.join(',')} FROM TestClass WHERE").should be_zero
              select_statement.index("Name = 'Richard'").should_not == -1
              select_statement.index("Email_Field = 'fake@email.com'").should_not == -1
              select_statement.index("LIMIT 1").should_not == -1
            end
            result = TestClass.find_or_initialize_by_Name_and_Email_Field('Richard', 'fake@email.com')
            result.Name.should == "Richard"
            result.Email_Field.should == "fake@email.com"
          end
        end

        context "with a hash argument containing additional attributes" do
          it "finds by the named arguments, but initializes by all values in the hash" do
            @client.should_receive(:query).with("SELECT #{@field_names.join(',')} FROM TestClass WHERE Name = 'Richard' LIMIT 1").and_return(nil)
            result = TestClass.find_or_initialize_by_Name("Name" => 'Richard', "Email_Field" => "foo@bar.com", "IsDeleted" => false)
            result.Name.should == "Richard"
            result.Email_Field.should == "foo@bar.com"
            result.IsDeleted.should be_false
          end
        end
      end
    end

    describe "#attributes" do
      it "returns a hash representing the object state" do
        attrs = { "Name" => "Jim Bob", "Number_Field" => 42 }
        obj = TestClass.new(attrs)
        attrs.keys.each {|attr| obj.attributes[attr].should == attrs[attr]}
      end
    end

    describe "#attributes=" do
      it "updates the object with the provided attributes" do
        obj = TestClass.new
        obj.Name.should be_nil
        obj.attributes = { "Name" => "foo" }
        obj.Name.should == "foo"
      end
    end

    describe "#save" do
      context "with a new object" do
        before do
          @obj = TestClass.new
          @obj.client = @client
          @obj.Name = "testname"
          @obj_double = double("object", "Id" => "foo")
        end

        it "creates the record remotely with the set attributes" do
          @client.should_receive(:create).and_return(@obj_double)
          @obj.save
        end

        it "includes only the createable attributes" do
          @client.should_receive(:create) do |clazz, attrs|
            attrs.all? {|attr, value| TestClass.createable?(attr).should be_true}
            @obj_double
          end

          @obj.save
        end

        it "sets the Id of the newly-persisted object" do
          @obj.Id.should be_nil
          @client.should_receive(:create).and_return(@obj_double)
          @obj.save
          @obj.Id.should == @obj_double.Id
        end
      end

      context "with an previously-persisted object" do
        before do
          @obj = TestClass.new
          @obj.client = @client
          @obj.Id = "rid"
        end

        it "updates the record with the attributes of the object" do
          @client.should_receive(:update).and_return("saved updates")
          @obj.save.should == "saved updates"
        end

        it "includes only the updateable attributes" do
          @client.should_receive(:update) do |clazz, id, attrs|
            attrs.all? {|attr, value| TestClass.updateable?(attr).should be_true}
          end

          @obj.save
        end
      end

      context "with exclusions argument" do
        before do
          @obj = TestClass.new
          @obj.Name = "testname"
          @obj.OwnerId = "someownerid"
          @obj_double = double("object", "Id" => "foo")
        end

        it "remove any listed fields from the attributes on create" do
          @client.should_receive(:create) do |clazz, attrs|
            attrs.include?("Name").should be_false
            attrs.include?("OwnerId").should be_true
            @obj_double
          end
          
          @obj.save(:exclusions => ["Name"])
        end
        
        it "remove any listed fields from the attributes on update" do
          @obj.Id = "foo"
          
          @client.should_receive(:update) do |clazz, id, attrs|
            attrs.include?("Name").should be_false
            attrs.include?("OwnerId").should be_true
          end
          
          result = @obj.save(:exclusions => ["Name"])
        end
      end

    end

    describe "#update" do
      it "returns itself with the updated attributes" do
        obj = TestClass.new
        obj.Id = "rid"
        obj.client = @client
        @client.should_receive(:update).with(TestClass, "rid", {"Name" => "newName"}).and_return(true)
        obj.update_attributes({"Name" => "newName"}).Name.should == "newName"
      end
    end

    describe "#delete" do
      it "deletes itself from the database and returns itself" do
        obj = TestClass.new
        obj.Id = "rid"
        obj.client = @client
        @client.should_receive(:delete).with(TestClass, "rid").and_return("destroyResponse")
        obj.delete.should == obj
      end
    end

    describe ".search" do
      it "submits a SOSL query" do
        @client.should_receive(:search).with("foo").and_return("bar")
        TestClass.search("foo").should == "bar"
      end
    end

    describe ".upsert" do
      it "submits an upsert request" do
        @client.should_receive(:upsert).with("TestClass", "externalField", "foo", "Name" => "Richard").and_return("gar")
        TestClass.upsert("externalField", "foo", "Name" => "Richard").should == "gar"
      end
    end

    describe ".label_for" do
      it "returns the label for a named attribute" do
        TestClass.label_for("Picklist_Field").should == "Picklist Label"
      end

      it "raises ArgumentError for unknown attributes" do
        lambda {
          TestClass.label_for("Foobar")
        }.should raise_error(ArgumentError)
      end
    end

    describe ".picklist_values" do
      it "returns an array of picklist values for an attribute" do
        TestClass.picklist_values("Picklist_Field").length.should == 3
      end

      it "raises ArgumentError for unknown attributes" do
        lambda {
          TestClass.picklist_values("Foobar")
        }.should raise_error(ArgumentError)
      end
    end

    describe ".field_type" do
      it "returns the field type for an attribute" do
        TestClass.field_type("Picklist_Field").should == "picklist"
      end

      it "raises ArgumentError for unknown attributes" do
        lambda {
          TestClass.field_type("Foobar")
        }.should raise_error(ArgumentError)
      end
    end

    describe ".updateable?" do
      it "returns the updateable flag for an attribute" do
        TestClass.updateable?("Picklist_Field").should be_true
        TestClass.updateable?("Id").should be_false
      end

      it "raises ArgumentError for unknown attributes" do
        lambda {
          TestClass.updateable?("Foobar")
        }.should raise_error(ArgumentError)
      end
    end

    describe ".createable?" do
      it "returns the createable flag for an attribute" do
        TestClass.createable?("IsDeleted").should be_false
        TestClass.createable?("Picklist_Field").should be_true
      end

      it "raises ArgumentError for unknown attributes" do
        lambda {
          TestClass.createable?("Foobar")
        }.should raise_error(ArgumentError)
      end
    end

    describe "#[]" do
      before do
        @obj = TestClass.new
        @obj.Id = "rid"
        @obj.client = @client
      end

      it "allows enumerable-like access to attributes" do
        @obj.Checkbox_Field = "foo"
        @obj["Checkbox_Field"].should == "foo"
      end

      it "returns nil if the attribute does not exist" do
        @obj["Foobar"].should == nil
      end
    end

    describe "#[]=" do
      before do
        @obj = TestClass.new
        @obj.Id = "rid"
        @obj.client = @client
      end

      it "allows enumerable-like setting of attributes" do
        @obj["Checkbox_Field"] = "foo"
        @obj.Checkbox_Field.should == "foo"
      end

      it "raises Argument error if attribute does not exist" do
        lambda {
          @obj["Foobar"] = "yes"
        }.should raise_error(ArgumentError)
      end
    end

    describe "form_for compatibility methods" do
      describe "#persisted?" do
        it "returns true if the object has an Id" do
          obj = TestClass.new
          obj.should_not be_persisted
          obj.Id = "foo"
          obj.should be_persisted
        end
      end

      describe "#new_record?" do
        it "returns true unless the object has an Id" do
          obj = TestClass.new
          obj.should be_new_record
          obj.Id = "foo"
          obj.should_not be_new_record
        end
      end

      describe "#to_key" do
        it "returns a unique object key" do
          TestClass.new.to_key.should_not == TestClass.new.to_key
        end
      end

      describe "#to_param" do
        it "returns the object Id" do
          obj = TestClass.new
          obj.Id = "foo"
          obj.to_param.should == "foo"
        end
      end
    end

    describe "#reload" do
      before do
        Databasedotcom::Sobject::Sobject.should_receive(:find).with("foo").and_return(double("sobject", :attributes => { "Id" => "foo", "Name" => "James"}))
      end

      it "reloads the object" do
        obj = TestClass.new
        obj.Id = "foo"
        obj.reload
      end

      it "resets the object attributes" do
        obj = TestClass.new
        obj.Id = "foo"
        obj.Name = "Jerry"
        obj.reload
        obj.Id.should == "foo"
        obj.Name.should == "James"
      end

      it "returns self" do
        obj = TestClass.new
        obj.Id = "foo"
        obj.Name = "Jerry"
        reloaded_obj = obj.reload
        reloaded_obj.should == obj
      end
    end
  end
end
