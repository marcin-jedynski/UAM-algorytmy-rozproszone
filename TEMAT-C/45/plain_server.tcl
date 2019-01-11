## ZeroMQ, 09.2018
#
proc err args {catch $args err; set err}
lappend auto_path ./zeromq
package re zmq
  #% 4.0.1

zmq context ctx
zmq socket s1 ctx REP
s1 config PLAIN_SERVER 1

zmq socket s3 ctx REP
s3 bind "inproc://zeromq.zap.01"
s3 readable www
proc www {} {
  set x [zmsg recv s3]
  puts "www x=$x"
  set version [lindex $x 0]
  set sequence [lindex $x 1]
  set domain  [lindex $x 2]
  # char *address = s_recv (zap);
  # char *identity = s_recv (zap);
  set mechanism [lindex $x 5]
  set username [lindex $x 6]
  set password [lindex $x 7]
  set y {}
  lappend y $version
  lappend y $sequence
  if {$username=="qqq" && $password=="123"} {
    lappend y 200
    lappend y "OK"
    lappend y "anonymous"
    lappend y ""
  } else {
    lappend y 400
    lappend y "Invalid username or password"
    lappend y ""
    lappend y ""
  }
  zmsg send s3 $y
}

# serwer
s1 bind "tcp://*:7777"
s1 readable qqq
proc qqq {} {
  set x [zmsg recv s1]; # czyta msg wieloczesciowy
  puts "x=$x"
  s1 send "odp na: $x"
}

vwait qqq





exit