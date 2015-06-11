require 'socket'
require 'pry'
require 'net/http'
require 'sinatra'

server = TCPServer.new 'localhost', 5000

def extract_file(path)
  puts "line 6"
  puts path
  puts "line 7"
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

def get_status_code(dir)
  # url = URI.parse("http://localhost:5000/index.html")
  # # http = Net::HTTP.new(url.host, url.port)          # Create a connection
  # # http.read_timeout = 1000
  # # headers, body = http.get(dir)      # Request the file
  # # headers, body = Net::HTTP::Get.new(dir.to_s)
  # # puts headers
  # # body
  # res = Net::HTTP.get_response(url.host, url.port)
  # res.read_timeout = 1000
  # res.code
  uri = URI.parse('http://localhost:5000/index.html')

  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri

    response = http.request request # Net::HTTPResponse object
  end
  
  # # if headers.code == "200"            # Check the status code   
  #   print body                        
  #   puts body
  #   puts headers.code
  #   puts headers.message
  # # else                                
  #   puts "#{headers.code} #{headers.message}" 
  # # end
  # headers.code
end

def status_code?(dir)
  url = URI.parse("http://localhost:5000/")
  puts "-3--------"
  puts url.host
  puts url.port
  puts "--4-------"
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Get.new(dir.to_s)
  res = http.request(request)
  puts "---5------"
  puts res
  puts res.body
  puts "----6-----"
  # res.body
end

# status_code?('index.html')
# puts 'eh'
# status_code?('')

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
    # socket.print file.contents
  end
end

def print_200(socket)
  socket.print "HTTP/1.1 200 OK\r\n" +
               "Connection: close\r\n"
end

loop do
  socket = server.accept
# response = <<eos
# HTTP/1.0 200 OK
# Date: Fri, 31 Dec 1999 23:59:59 GMT
# Content-Type: text/html
# Content-Length: 1354
# eos
# Map extensions to their content type

  # socket.print each_response_header(socket)
  # socket.puts "you did it"
  # binding.pry
  extracted_file = extract_file(socket.gets || '/index.html') 

  # puts "line 42"
  # puts socket.gets 
  # puts "line 44"
  # extracted_file = socket.gets
  # puts "line 43"
  # puts extracted_file
  # puts "line 45"

  # puts status_code?

  case extracted_file
  when '/index.html'
    extracted_file?(extracted_file, socket)
  when '/'
    print_200(socket)
    socket.print Dir["http://localhost:5000/"]
    # socket.print Dir[directory?]
    # use_body_directory(socket)
  else
    socket.print "HTTP/1.1 404 Not Found\r\n"
  end


  puts File.open('index.html')

  # status_code?('index.html')




  socket.close
end

  # puts "line 112"
  # puts get_status_code('index.html')
  # puts "line 114"

