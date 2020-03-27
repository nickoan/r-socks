require 'eventmachine'
require 'r_socks/http_proxy_response_codes'

module RSocks
  class TargetConnectionHandler < EM::Connection

    def initialize(client, config)
      @client = client
      @config = config
    end

    def connection_completed
      port, ip = Socket.unpack_sockaddr_in(get_peername)
      puts "success connected to #{ip}:#{port}"
      if @config.proxy_type == :http
        @client.send_data(RSocks::HttpProxyResponseCodes::SUCCESS)
      end
      @client.proxy_incoming_to(self, @config.proxy_buffer_size)
      proxy_incoming_to(@client, @config.proxy_buffer_size)
    end

    def receive_data(data)
      @client.send_data(data)
    end

    def proxy_target_unbound
      close_connection
    end

    def unbind
      @client.close_connection_after_writing
    end
  end
end