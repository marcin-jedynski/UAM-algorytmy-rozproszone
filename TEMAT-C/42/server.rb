require 'Matrix'
require 'ffi-rzmq'

context = ZMQ::Context.new(1)
request = ZMQ::Message.create
responder = context.socket(ZMQ::REP)
responder.bind("tcp://*:5555")

while true
    multiplier = 0

    responder.recvmsg(request)
    multiplier = Marshal.load(request.copy_out_string)
    puts "otrzymany mnoznik #{multiplier}"

    reply = ZMQ::Message.new(Marshal.dump("SET"))
    responder.sendmsg(reply)

    responder.recvmsg(request)
    matrix = Marshal.load(request.copy_out_string)
    puts "otrzymana macierz #{matrix}"
    matrix = matrix * multiplier

    reply = ZMQ::Message.new(Marshal.dump(matrix))
    responder.sendmsg(reply)
end