# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require 'celluloid/eventsource'

class LogStash::Inputs::Sse < LogStash::Inputs::Base
  config_name "sse"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "json" 

  # The message string to use in the event.
  config :url, :validate => :string, :default => "127.0.0.1:10001/v1/stats/stream"
  config :event_type, :validate => :string, :default => "metric"


  public
  def register
    @event_source = Celluloid::EventSource.new("http://" + @url)
  end 

  def run(queue)


      @event_source.on_open do
        puts "Connection opened"
      end

      @event_source.on(@event_type.to_sym) do |event|
        puts "Message: #{event.data}"
        event = LogStash::Event.new("message" => @message)
        decorate(event)
        queue << event
      end

      @event_source.on_error do |message|
        puts "Response status #{message[:status_code]}, Response body #{message[:body]}"
      end

    end
  end 

end 