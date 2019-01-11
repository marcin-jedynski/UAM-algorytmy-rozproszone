require 'ffi-rzmq'

# This example shows the basics of a CURVE-secured REP/REQ setup between
# a Server and Client. This is the minimal required setup for authenticating
# a connection between a Client and a Server. For validating the Client's authentication
# once the initial connection has succeeded, you'll need a ZAP handler on the Server.

# Build the Server's keys
server_public_key, server_private_key = ZMQ::Util.curve_keypair

puts server_public_key
File.open('pub_key.txt', 'w') { |file| file.write(server_public_key) }


context = ZMQ::Context.new
bind_point = "tcp://127.0.0.1:4455"

##
# Configure the Server
##
server = context.socket ZMQ::REP

server.setsockopt(ZMQ::CURVE_SERVER, 1)
server.setsockopt(ZMQ::CURVE_SECRETKEY, server_private_key)

server.bind(bind_point)

##

server_response = "Hello Client!"
server.recv_string(server_message = '')
puts "Server received:\n#{server_message}\nreplying with #{server_response}"

server.send_string(server_response)

puts "Finished"
server.close
context.terminate