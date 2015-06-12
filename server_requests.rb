require_relative 'server_file_cabinet'

class ServerRequests

  attr_reader :file_cabinet
  
  def initialize
    @file_cabinet = ServerFileCabinet.new
  end
  
  def print_200(socket)
    socket.print "HTTP/1.1 200 OK\r\n" 
  end

  def print_404(socket)
    socket.print "HTTP/1.1 404 Not Found\r\n"
  end

  def print_405(socket)
    socket.print "HTTP/1.1 405 Method Not Allowed\r\n"
  end

  def patch_request(socket, extracted_file)
    case extracted_file
    when '/patch-content.txt'
      socket.print "HTTP/1.1 204 No Content\r\n"
    else
      print_404(socket)
    end
  end

  def get_request(socket, extracted_file)
  file_cabinet = ServerFileCabinet.new
    case extracted_file
    # when '/index.html'
    #   extracted_file?(extracted_file, socket)
    when '/'
      print_200(socket)
    when '/redirect'
      socket.print "HTTP/1.1 302 Moved Temporarily\r\n" +
                   "location: http://localhost:5000/\r\n"
    when '/logs'
      socket.print "HTTP/1.1 401 Authentication Required\r\n" 
    when '/method_options'
      print_200(socket)
    when '/form'
      print_200(socket)
    when '/partial_content.txt'
      socket.print "HTTP/1.1 206 Partial Content\r\n"
    when '/patch-content.txt'
      print_200(socket)
    when (/^.*\.(jpeg|png|gif)$/)
      file_cabinet.show_image(extracted_file, socket)
    else
      print_404(socket)
    end
  end

  def post_request(socket, extracted_file)
    case extracted_file
    when '/form'
      print_200(socket)
    else
      print_405(socket)
    end
  end

  def put_request(socket, extracted_file)
    case extracted_file
    when '/form'
      print_200(socket)
    else
      print_405(socket)
    end
  end

  def options_request(socket, extracted_file)
    case extracted_file
    when '/method_options'
      print_200(socket)
    else
      print_404(socket)
    end
  end

  def delete_request(socket, extracted_file)
    case extracted_file
    when '/form'
      print_200(socket)
    else
      print_404(socket)
    end
  end

end
