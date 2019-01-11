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
  puts "Generating #{number} random numbers"

  for i in (1..number) do
    socket.send_string( "%i (worker id = %05i)" % [rand(1..10000), id], i == number ? 0 : ZMQ::SNDMORE )
  end
end
