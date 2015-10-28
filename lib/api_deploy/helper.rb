require 'socket'

module ApiDeploy
  class Helper  
    class << self
      
      # def get_free_tcp_port
      #   socket = Socket.new(:INET, :STREAM, 0)
      #   socket.bind(Addrinfo.tcp("127.0.0.1", 0))
      #   socket.listen(Socket::SOMAXCONN)
      #
      #   return socket.local_address.ip_port.to_s
      # end
      
      def available_port
        server = TCPServer.new('127.0.0.1', 0)
        server.addr[1].to_s
      ensure
        server.close if server
      end
      
    end
  end
end