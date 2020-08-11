require 'webrick'
TIMEOUT_SECONDS = 60 * 60 # 1 hour
# как обратится
server = WEBrick::HTTPServer.new :Port => 8015, :BindAddress => '0.0.0.0'

@last_time = Time.now.to_f





server.mount_proc '/' do |req, res|
  res.body = { readiness: 'OK' }
  res.status = "200"
  p req.body
  p req.header
  p req.remote_ip
  p req.request_method
  p req.http_version
  p req.query_string
  
end

server.mount_proc '/readiness' do |req, res|
  res.body = { readiness: 'OK' }
  res.status = "200"
  p req.body
  p req.header
  p req.remote_ip
  p req.request_method
  p req.http_version
  p req.query_string
  
  
#  res.request_method = req.request_method
#  res.request_uri = req.request_uri
#  res.request_http_version = req.http_version
#  res.keep_alive = req.keep_alive?
#
#  res.body << "Received request from #{req.remote_ip} (method: #{req.request_method} | version: #{req.http_version})\n"
#  res.body << "Raw headers: #{req.raw_header}\n"
#  res.body << "Parsed Headers: #{req.header}\n"
#  res.body << "Cookies: #{req.cookies}\n"
#  res.body << "Request uri: #{req.request_uri}\n"
#  res.body << "path: #{req.path}\n"
#  res.body << "Script name: #{req.script_name}\n"
#  res.body << "Path info: #{req.path_info}\n"
#  res.body << "Query string: #{req.query_string}\n"
#  res.body << "Body: #{req.body}\n"
#  res.body << "---\n"
#  res['Content-Type'] = 'application/json'
end



#server.mount_proc '/request/domain/7532' do |req, res|
#  res['Content-Type'] = 'application/json'
#  res.body = '{"result":"Successful","error":null,"id":1}'
#  res.status = "200"
#  p req.body
#  p req.header
#  p req.remote_ip
#  p req.request_method
#  p req.http_version
#  p req.query_string
  
  
#  res.request_method = req.request_method
#  res.request_uri = req.request_uri
#  res.request_http_version = req.http_version
#  res.keep_alive = req.keep_alive?

#  res.body << "Received request from #{req.remote_ip} (method: #{req.request_method} | version: #{req.http_version})\n"
#  res.body << "Raw headers: #{req.raw_header}\n"
#  res.body << "Parsed Headers: #{req.header}\n"
#  res.body << "Cookies: #{req.cookies}\n"
#  res.body << "Request uri: #{req.request_uri}\n"
#  res.body << "path: #{req.path}\n"
#  res.body << "Script name: #{req.script_name}\n"
#  res.body << "Path info: #{req.path_info}\n"
#  res.body << "Query string: #{req.query_string}\n"
#  res.body << "Body: #{req.body}\n"
#  res.body << "---\n"
#  res['Content-Type'] = 'application/json'
#end



#server.mount_proc '/selfbody' do |req, res|
#  res.body = req.body
#  res['Content-Type'] = 'application/json'
#end

#server.mount_proc '/' do |req, res|
#  res.body = 'foobar'
#  res['Content-Type'] = 'application/json'
#end


server.mount_proc '/error' do |req, res|
    res.body = "500"
    res.status = "500"
    res['Content-Type'] = 'application/json'
  end

server.mount_proc '/selfheaders' do |req, res|
  res.body = req.header.map{ |k,v| "#{k}: #{v}"}.join("\n")
  res['Content-Type'] = 'text/html'
end



server.mount_proc '/specificheaders' do |req, res|
  res.body = if req.header['admin'] == ['true']
    'u r admin!'
  else
    'need an "admin: true" header'
  end
  res['Content-Type'] = 'text/html'
end



server.mount_proc '/rce' do |req, res|
  begin
    value = req.body
    puts "running '#{value}':"
    result = %x[#{value}]
    puts result
    res.body = result
    res['Content-Type'] = 'text/html'    
  rescue Exception => e
    res.body = "error when running injection: #{e.to_s}"
    res['Content-Type'] = 'text/html'
  end
end




server.mount_proc '/.git_index' do |req, res|
  res.body = 'you have found the git index!'
  res['Content-Type'] = 'text/html'
end




begin
  Timeout::timeout(TIMEOUT_SECONDS) do
    server.start
    trap('INT') { server.stop }
  end
ensure
  server.stop
end
