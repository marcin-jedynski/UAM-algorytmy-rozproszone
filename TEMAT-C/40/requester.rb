#!/usr/bin/env ruby
require 'rubygems'
require 'ffi-rzmq'

$is_registered = false
$transmitting = false
filter = 'clear'
response = ''
status_update = ''
$random_id = "%04d" % rand(1..1000)
context = ZMQ::Context.new(1)
requester = context.socket(ZMQ::REQ)
orders = context.socket(ZMQ::SUB)
status = context.socket(ZMQ::PUSH)

requester.connect("tcp://localhost:5050")
status.connect("tcp://localhost:5070")
orders.setsockopt(ZMQ::SUBSCRIBE, filter)
orders.setsockopt(ZMQ::LINGER, 0)


poller = ZMQ::Poller.new
poller.register(orders, ZMQ::POLLIN)


def display()
    clear()
    puts("Node id: %s" % $random_id)
    puts ("Node registered: %s" % $is_registered)
    puts ("Node transmitting: %s" % $transmitting)
end

def getDecision()
    puts("Begin transmittion? 'y'/'n'")
    decision = gets().chomp()
    return decision
end

def clear()
    system "clear" or system "cls"
end

while true
    if  not $is_registered
        requester.send_string('register')
        requester.recv_string(response)
        if response == 'registered'
            $is_registered = true
            puts "Client now is registered"
        end
    else
        display()
        decision = getDecision()
        if decision == 'y'
            requester.send_string('clear channel' + ' ' + $random_id)
            puts("requesting channel")
            requester.recv_string(response)
            puts("request response: %s" % response)
            if response == 'channel clear'
                $transmitting = true
                status_update = ''
                display()
                orders.connect("tcp://localhost:5060")
                loop do
                    orders.recv_string(status_update, ZMQ::DONTWAIT)
                    if not status_update.empty? 
                        msg, transmission_counter, id = status_update.split()
                        if id != $random_id
                            $transmitting = false
                            status.send_string(transmission_counter)
                            # display()
                            orders.disconnect("tcp://localhost:5060")
                            break
                        end
                    else
                        puts(Time.now.to_f)
                    end
                end
            end
        end
    end 
end




