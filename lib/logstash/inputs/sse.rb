# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require 'celluloid/eventsource'


class LogStash::Inputs::Sse < LogStash::Inputs::Base
  config_name "sse"

  # The default code is JSON
  default :codec, "json" 

  # Set the url from where to consume the SSE stream
  config :url, :validate => :string, :required => true
  # Specifies the event type to pick out of the stream. The default is "event: metric"
  config :event_type, :validate => :string, :default => "metric"


  public
  def register

  end 

  def run(input_queue)

    @event_source = Celluloid::EventSource.new(@url) do |conn|

        conn.on_open do
          @logger.info("New server sent events input: #{@url}")
        end

       conn.on(@event_type.to_sym) do |payload|
          @codec.decode(payload.data) do |event|
          decorate(event)
          input_queue << event
          end
        end

        conn.on_error do |message|
          @logger.error("Response status #{message[:status_code]}, Response body #{message[:body]}")
        end
    end
    sleep 
  end
end 