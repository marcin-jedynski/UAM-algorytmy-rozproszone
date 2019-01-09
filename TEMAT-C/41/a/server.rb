#!/usr/bin/env ruby

require 'rubygems'
require 'ffi-rzmq'

message = "ala ma kota"
filter = 'test'
request=''

context = ZMQ::Context.new(1)


socket = context.socket(ZMQ::REP)
socket.bind("tcp://*:5555")

receiver = context.socket(ZMQ::PULL)
receiver.bind("tcp://*:5558")

publisher = context.socket(ZMQ::PUB)
publisher.bind("tcp://*:5556")

socket.recv_string(request)
if request == 'request filter'
    socket.send_string(filter)
end

receiver.recv_string(request)
if request == 'ready'
    publisher.send_string(filter +' '+message)
end





