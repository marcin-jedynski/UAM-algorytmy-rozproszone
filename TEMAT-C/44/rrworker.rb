#!/usr/bin/env ruby

# author: Oleg Sidorov <4pcbr> i4pcbr@gmail.com
# this code is licenced under the MIT/X11 licence.

require 'rubygems'
require 'ffi-rzmq'

id = rand(1..10000)
context = ZMQ::Context.new
socket = context.socket(ZMQ::REP)
socket.connect('tcp://localhost:5560')

loop do
  socket.recv_string(message = '')
  puts "Received request: #{message}"
  number = rand(1..20)
  number.times do
    socket.send_string("World (worker id = %05i)" % id, ZMQ::SNDMORE)

  end
end
