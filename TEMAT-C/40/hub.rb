#!/usr/bin/env ruby
require 'rubygems'
require 'ffi-rzmq'

response = ''
statusUpdate = ''
clientCounter = 0
transsmissionCounter = 0
filter = 'clear'
statusHash = {}

context = ZMQ::Context.new(1)
listener = context.socket(ZMQ::REP)
commander = context.socket(ZMQ::PUB)
statuspoller = context.socket(ZMQ::PULL)
poller = context.socket(ZMQ::POLL)

listener.bind("tcp://*:5050")
commander.bind("tcp://*5060")
statuspoller.bind("tcp://*5070")

poller = ZMQ::Poller.new
poller.register(statuspoller, ZMQ::POLLIN)

while true

    listener.recv_string(response)
    if response == "clear channel"
        transsmissionCounter += 1
        statusHash[transsmissionCounter] = 0
        commander.send_string(filter + " " + transsmissionCounter.to_s)
        loop do
            poller.poll(:blocking)
            poller.readables.each do |socket|
              if socket === statuspoller
                socket.recv_string(statusUpdate)
                if statusUpdate.include?(transsmissionCounter.to_s) then statusHash[transsmissionCounter] += 1 end
              end
            end
            if statusHash[transsmissionCounter] == clientCounter then break end
        end
        listener.send_string("channel clear")

    elsif response == "register"
        clientCounter +=1 
        listener.send_string("registered")
    else
        listener.send_string("unknown request")
    end
end