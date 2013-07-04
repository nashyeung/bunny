require "spec_helper"

if RUBY_VERSION.to_f <= 1.8.7
  describe "Publishing a message to the default exchange" do
    let(:connection) do
      c = Bunny.new(:user => "bunny_gem", :password => "bunny_password", :vhost => "bunny_testbed")
      c.start
      c
    end

    after :all do
      connection.close if connection.open?
    end


    context "with all default delivery and message properties" do
      it "routes messages to a queue with the same name as the routing key" do
        connection.should be_threaded
        ch = connection.create_channel

        q  = ch.queue("", :exclusive => true)
        x  = ch.default_exchange

        x.publish("xyzzy", :routing_key => q.name).
          publish("xyzzy", :routing_key => q.name).
          publish("xyzzy", :routing_key => q.name).
          publish("xyzzy", :routing_key => q.name)

        sleep(1)
        q.message_count.should == 4

        ch.close
      end
    end


    context "with all default delivery and message properties" do
      it "routes the messages and preserves all the metadata" do
        connection.should be_threaded
        ch = connection.create_channel

        q  = ch.queue("", :exclusive => true)
        x  = ch.default_exchange

        x.publish("xyzzy", :routing_key => q.name, :persistent => true)

        sleep(1)
        q.message_count.should == 1

        envelope, headers, payload = q.pop

        payload.should == "xyzzy"

        headers[:content_type].should == "application/octet-stream"
        headers[:delivery_mode].should == 2
        headers[:priority].should == 0

        ch.close
      end
    end


    context "with all default delivery and message properties on a single-threaded connection" do
      let(:connection) do
        c = Bunny.new(:user => "bunny_gem", :password => "bunny_password", :vhost => "bunny_testbed", :threaded => false)
        c.start
        c
      end

      it "routes messages to a queue with the same name as the routing key" do
        connection.should_not be_threaded
        ch = connection.create_channel

        q  = ch.queue("", :exclusive => true)
        x  = ch.default_exchange

        x.publish("xyzzy", :routing_key => q.name).
          publish("xyzzy", :routing_key => q.name).
          publish("xyzzy", :routing_key => q.name).
          publish("xyzzy", :routing_key => q.name)

        sleep(1)
        q.message_count.should == 4

        ch.close
      end
    end
  end
end
