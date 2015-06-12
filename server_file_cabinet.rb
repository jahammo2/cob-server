class ServerFileCabinet

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
    "/Users/LtLiberty/sb/cob-server/cob_spec/public"
  end

  def extracted_file?(extracted_file, socket)
    extracted_file = extracted_file.split("/")[-1]
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

  def create_directory_array
    dir_array = []
    Dir.foreach("/Users/LtLiberty/sb/cob-server/cob_spec/public") { |file| dir_array.push(file.split("/")[-1]) }
    puts "---3---"
    puts dir_array
    puts "---34--"
    dir_array
  end

  def show_image(image,socket)
    create_directory_array
    image = directory? + image
    if File.exist?(image)
      File.open(image) do |file|
        socket.print File.read(file)
        IO.copy_stream(file,socket)
      end
    else
      socket.print "HTTP/1.1 404 Not Found\r\n" 
    end
  end

end
