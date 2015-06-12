require 'socket'
require 'pry'
require 'net/http'
require_relative 'server_requests'

server_requests = ServerRequests.new

server = TCPServer.new 'localhost', 5000

def extract_file(path)
  path.split(" ")[1]
end

CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

# Treat as binary data if content type cannot be found
DEFAULT_CONTENT_TYPE = 'application/octet-stream'

def content_type(path)
  ext = File.extname(path).split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

def directory?
  "/Users/LtLiberty/sb/cob-server/*"
end

def extracted_file?(extracted_file, socket)
  extracted_file.split("/")[-1]
  if File.exist?(extracted_file)
    File.open(extracted_file) do |file|
      socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: #{content_type(file)}\r\n" +
                   "Content-Length: #{file.size}\r\n" +
                   "Connection: close\r\n"

      socket.print "\r\n"
      socket.print File.read(extracted_file)
      socket.print "=====---------========"
      socket.puts File.read(extracted_file)
      socket.puts "=====---------========"

      IO.copy_stream(file, socket)
    end
  else
    socket.print "HTTP/1.1 404 Not Found\r\n" 
  end
end

def use_body_directory(socket)
  File.open('index.html') do |file|
    IO.copy_stream(file, socket)
  end
end



def extract_request(request)
  @extracted_method = request.split(" ")[0] || 'GET'
  @extracted_file = request.split(" ")[1] || 'index.html'
end

loop do
  socket = server.accept
  extract_request(socket.gets)
  
  puts "-------1--------"
  puts @extracted_method
  puts "-------2--------"
  puts @extracted_file
  puts "-------12-------"

  case @extracted_method
  when 'GET'
    server_requests.get_request(socket,@extracted_file)
  when 'PUT'
    server_requests.put_request(socket,@extracted_file)
  when 'PATCH'
    server_requests.patch_request(socket,@extracted_file)
  when 'POST'
    server_requests.post_request(socket,@extracted_file)
  when 'DELETE'
    server_requests.delete_request(socket,@extracted_file)
  when 'OPTIONS'
    server_requests.options_request(socket,@extracted_file)
  else
    puts 'probably a head request'
  end

  socket.close
end

