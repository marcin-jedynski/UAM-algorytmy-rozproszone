require 'ffi-rzmq'

# This example shows the basics of a CURVE-secured REP/REQ setup between
# a Server and Client. This is the minimal required setup for authenticating
# a connection between a Client and a Server. For validating the Client's authentication
# once the initial connection has succeeded, you'll need a ZAP handler on the Server.


# Build the Client's keys
client_public_key, client_private_key = ZMQ::Util.curve_keypair

context = ZMQ::Context.new
bind_point = "tcp://127.0.0.1:4455"
server_public_key = ''
File.open('pub_key.txt', 'r') { |file| server_public_key = file.readline() }
puts server_public_key

##
# Configure the Client to talk to the Server
##
client = context.socket ZMQ::REQ
client.setsockopt(ZMQ::CURVE_SERVERKEY, server_public_key)
client.setsockopt(ZMQ::CURVE_PUBLICKEY, client_public_key)
client.setsockopt(ZMQ::CURVE_SECRETKEY, client_private_key)

client.connect(bind_point)

##
# Show that communication still works
##
text = "Litwo! Ojczyzno moja! ty jesteś jak zdrowie.
Ile cię trzeba cenić, ten tylko się dowie,
Kto cię stracił. Dziś piękność twą w całej ozdobie
Widzę i opisuję, bo tęsknię po tobie.
Panno Święta, co jasnej bronisz Częstochowy
I w Ostrej świecisz Bramie! Ty, co gród zamkowy
Nowogródzki ochraniasz z jego wiernym ludem!
Jak mnie dziecko do zdrowia powróciłaś cudem
(Gdy od płaczącej matki pod Twoją opiekę
Ofiarowany, martwą podniosłem powiekę
I zaraz mogłem pieszo do Twych świątyń progu
Iść za wrócone życie podziękować Bogu),
Tak nas powrócisz cudem na Ojczyzny łono.
Tymczasem przenoś moję duszę utęsknioną
Do tych pagórków leśnych, do tych łąk zielonych,
Szeroko nad błękitnym Niemnem rozciągnionych;
Do tych pól malowanych zbożem rozmaitem,
Wyzłacanych pszenicą, posrebrzanych żytem;
Gdzie bursztynowy świerzop, gryka jak śnieg biała,
Gdzie panieńskim rumieńcem dzięcielina pała,
A wszystko przepasane, jakby wstęgą, miedzą
Zieloną, na niej z rzadka ciche grusze siedzą."
client_message = "Hello Server!"

puts "Client sending: #{text}"
client.send_string text
client.recv_string(response = '')
puts "Client has received: #{response}"

puts "Finished"

client.close
context.terminate