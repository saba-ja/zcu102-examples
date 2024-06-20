# Reference: https://support.xilinx.com/s/article/75416?language=en_US
# Set target into JTAG mode
connect
puts "-------------------------------------"
puts "Reset and setup system into JTAG mode"
puts "-------------------------------------"

targets -set -nocase -filter {name =~ "*PSU*"}
puts "stop PSU"
stop

puts "mwr to set JTAG mode"
after 1000
mwr  0xff5e0200 0x0100

puts "rst -system"
rst -system
after 1000

puts "done"

