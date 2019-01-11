## ZeroMQ, 09.2018
# + security, metoda PLAIN + ZAP
# + zmq ma 3 metody: NULL, PLAIN, CURVE
# + opisy security w zmq:
#  https://rfc.zeromq.org/spec:23/ZMTP/
#  https://rfc.zeromq.org/spec:27/ZAP/
#  https://rfc.zeromq.org/spec:24/ZMTP-PLAIN/
#  http://hintjens.com/blog:45
#  http://hintjens.com/blog:48
#  http://hintjens.com/blog:49
# + ZAP: gdzie kod sprawdzajacy username/password ?
#  trzeba podlaczyc handler pod "inproc://zeromq.zap.01"
#  dziwna reakcja na bledne haslo po stronie klienta(?)
#    to chyba blad w libzmq 4.1.5 ?!?!
#  mozna obejsc ten blad przez flage DONTWAIT w send i recv;
#    ale nie do konca...
#  moze potrzebna nowsza wersja libzmq ?!?!
#    okazuje sie ze niezbedna jest wersja libzmq 4.2.5
#    zmodyfikowana wersja tclzmq
#    oraz wlaczenie draftowych flag monitora
#      ktore moga nie dzialac... (chyba nie dzialaja prawidlowo?!)
#    wszystko razem dosc kontrowersyjne...
#      info o blednym hasle przychodzi jako zdarzenie...
#  WNIOSEK: uzywac starej wersji i triku z CONNECTED
#    do wykrywania czy uwierzytelnianie sie udalo...
#    jednak jest pewien problem z tym podejsciem:
#      nie wiadomo ile zdarzen (DIS)CONNECTED przyjdzie i ktore jest ostnie...
#
exec tclkit8.6b1 alr_zmq03ser.tcl &
  #% 21244
proc err args {catch $args err; set err}
lappend auto_path ./zeromq
package re zmq
  #% 4.0.1
zmq version
  #% 4.1.5

zmq context ctx
zmq socket s2 ctx REQ
s2 config IDENTITY 1234
s2 config PLAIN_USERNAME "qqq"
s2 config PLAIN_PASSWORD "123"
zmq monitor ctx s2 eee
proc eee args {
  puts "[info level 0]"
  if {[lindex $args 0 1]=="CONNECTED"} {set ::CONNECTED 1}
  if {[lindex $args 0 1]=="DISCONNECTED"} {set ::CONNECTED 0}
}
  # + NIE pokazuje bledu przy connect z blednym haslem ?!?!?!
  # + po przejsciu na nowa wersje i zmianach w tclzmq pokazuje...
  #  dlaczego pokazuje tez CONNECT_RETRIED ?!?! blad ?
  # + cos jest nie tak z tymi komunikatami...
  #  dlaczego nie ma HANDSHAKE_SUCC
  # + przy starej wersji libzmq mozna sie posluzyc flagami
  #  CONNECTED i DISCONNECTED (!!!)

# klient
set CONNECTED 0; s2 connect "tcp://localhost:7777"; after 300; update; set CONNECTED
  #% 0
  #% 1
  # + connect wysyla zdarzenia do kolejki zdarzen...
  # + jesli CONNECTED tzn. ze uwierzytelnienie sie udalo i mozna wyw. send/recv
  # + jest problem ani vwait ani update nie dzialaja prawidlow... ?!?!?!
  #  "after 300; update" to prymitywne rozwiazanie bez gwarancji...

s2 send "a ku ku 1"
  #%
s2 recv
  #% odp na: {a ku ku 1}
s2 recv DONTWAIT

s2 disconnect "tcp://localhost:7777"
s2 config PLAIN_PASSWORD "123"
s2 config PLAIN_PASSWORD "1234"
  # + reakcja na bledne haslo jest dziwna... zawieszenie?
  #  jak to wykryc ?!?!?!?!!?!?
  #  okazuje sie ze flaga DONTWAIT pomaga...
  #  zwraca "Resource temporarily unavailable"
  # + po uaktualnieniu tclzmq oraz po przejsciu na libzmq 4.2.5 (zamiast 4.1.5)
  #  otrzymujemy informacje HANDSHAKE_FAILED_AUTH...
  #  czy to wystarczy?  to jest tylko DRAFT...
  # + jesli w trybie bez polaczenia wywolac send, to potem jest problem bo
  #  zmq nie pozwala na drugie send; jedyne wyjcie to "s2 destroy" i utworzyc s2 od nowa...

s2 config
  #% {SNDHWM 1000} {RCVHWM 1000} {AFFINITY 0} {IDENTITY 1234} {RATE 100} {RECOVERY_IVL 10000} {SNDBUF 0} {RCVBUF 0} {RCVMORE 0} {EVENTS POLLOUT} {TYPE 3} {LINGER -1} {RECONNECT_IVL 100} {BACKLOG 100} {RECONNECT_IVL_MAX 0} {MAXMSGSIZE -1} {MULTICAST_HOPS 1} {RCVTIMEO -1} {SNDTIMEO -1} {LAST_ENDPOINT tcp://localhost:7777} {TCP_KEEPALIVE -1} {TCP_KEEPALIVE_CNT -1} {TCP_KEEPALIVE_IDLE -1} {TCP_KEEPALIVE_INTVL -1} {IMMEDIATE 0} {MECHANISM PLAIN} {PLAIN_SERVER 0} {PLAIN_USERNAME qqq} {PLAIN_PASSWORD 1234} {CURVE_SERVER {<no libsodium>}} {CURVE_PUBLICKEY {<no libsodium>}} {CURVE_SECRETKEY {<no libsodium>}} {CURVE_SERVERKEY {<no libsodium>}} {ZAP_DOMAIN {}} {IPV6 0}

zmq have_libsodium
  #% 1

s2 destroy








