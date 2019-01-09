#!/usr/bin/env ruby

require 'rubygems'
require 'ffi-rzmq'

request = ''
pong = 'pong'

context = ZMQ::Context.new(1)


socket = context.socket(ZMQ::REP)
socket.bind("tcp://*:5555")
counter = 0

while true
    resp = "#{pong} #{counter}"
    socket.recv_string(request)
    socket.send_string(resp)
    counter += 1
end







