module ApiDeploy
  class Helper  
    class << self
      
      def get_free_port
        server = TCPServer.new('127.0.0.1', 0)
        port = server.addr[1]
  
        return port.to_s
      end
      
    end
  end
end