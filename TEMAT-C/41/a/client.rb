#!/usr/bin/env ruby

require 'rubygems'
require 'ffi-rzmq'

context = ZMQ::Context.new(1)

response = ''
requester = context.socket(ZMQ::REQ)
requester.connect("tcp://localhost:5555")

subscriber = context.socket(ZMQ::SUB)
subscriber.connect("tcp://localhost:5556")

sender = context.socket(ZMQ::PUSH)
sender.connect("tcp://localhost:5558")

requester.send_string("request filter")
requester.recv_string(response)
subscriber.setsockopt(ZMQ::SUBSCRIBE, response)
sender.send_string('ready')

subscriber.recv_string(response)

puts response



