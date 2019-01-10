#!/usr/bin/env ruby

# author: Oleg Sidorov <4pcbr> i4pcbr@gmail.com
# this code is licenced under the MIT/X11 licence.

require 'rubygems'
require 'ffi-rzmq'
id = rand(1..10000)
context = ZMQ::Context.new
socket = context.socket(ZMQ::REQ)
socket.connect('tcp://localhost:5559')

string = "Generate random numbers (client id = %05i)" % id
socket.send_string(string)
puts "Sending string [#{string}]"
do
  socket.recv_string(message = '')
  puts "Received: #{request}[#{message}]"
while socket.more_parts?
