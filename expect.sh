#!/usr/bin/expect

set file [open "routes.cli" r]

set passwordFile "password.txt"

# Чтение пароля из файла
set password [exec cat $passwordFile]

spawn ssh msa@192.168.2.1
expect "password:"
send "$password\r"

expect "(config)>"

while {[gets $file line] != -1} {
    send "$line\r"
    expect "(config)>"
}

send "exit/r"
close $file
exit
