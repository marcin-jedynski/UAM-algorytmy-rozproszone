require 'Matrix'
require 'ffi-rzmq'

#wprowadzc macierz w formacie np Matrix[[4, 8], [12, 16]]

context = ZMQ::Context.new(1)
response = ZMQ::Message.create
requester = context.socket(ZMQ::REQ)
requester.connect("tcp://localhost:5555")
puts "Wprowadz macierz:"
matrix  = eval(gets())

puts "Wprowadz mnoznik:"
multiplier  = gets().to_i
request = ZMQ::Message.new(Marshal.dump(multiplier))
requester.sendmsg(request)
requester.recvmsg(response)

if Marshal.load(response.copy_out_string) == 'SET'
    request = ZMQ::Message.new(Marshal.dump(matrix))
    requester.sendmsg(request)
    requester.recvmsg(response)
    puts "zwrócona macierz #{Marshal.load(response.copy_out_string)}"
else
    puts 'Something went wrong'
end

