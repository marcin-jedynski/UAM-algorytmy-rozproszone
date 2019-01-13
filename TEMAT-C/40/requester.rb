#!/usr/bin/env ruby
require 'rubygems'
require 'ffi-rzmq'

is_registered = false
transmitting = false
response = ''

context = ZMQ::Context.new(1)
requester = context.socket(ZMQ::REQ)
orders = context.socket(ZMQ::SUB)
status = context.socket(ZMQ::PUSH)

poller = ZMQ::Poller.new
poller.register(statuspoller, ZMQ::POLLIN)

requester.connect("tcp://localhost:5050")
status.connect("tcp://localhost:5070")
orders.connect("tcp://localhost:5060")
orders.setsockopt(ZMQ::SUBSCRIBE, response)

while true
    if  not is_registered
        requester.send_string('register')
        requester.recv_string(response)
        if response == 'registered'
            is_registered = true
            puts "Client now is registered"
        end
    else
        decision = display()
        if decision == 'y'
            requester.send_string('clear channel')
            requester.receive_string(response)
            if response == 'channel clear' then transmitting = true end
        end
    end 
end

def display()
    puts ("Node registered: %s" % is_registered)
    puts ("Node transmitting: %s" % transmitting)
    puts("Begin transmittion? 'y'/'n'")
    decision = gets().chomp()
    return decision
end



