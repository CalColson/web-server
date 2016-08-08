require 'socket'
require 'json'

host = 'localhost'
port = 2000

response = []
request = []

puts "Do you want to GET or POST?:"

case gets.chomp

when "GET"
	puts "What file would you like?"
	file = gets.chomp
	request << "GET #{file} HTTP/1.0"

when "POST"
	puts "What's your viking's name?:"
	name = gets.chomp
	puts "And his email address?:"
	email = gets.chomp

	results = {viking: {name: name, email: email}}.to_json
	request << "POST localhost HTTP/1.0"
	request << "Content-Length: #{results.length}"
	request << "\n"
	request << results

else
	puts "I did not understand your command"
end

socket = TCPSocket.open(host, port)
puts "Socket opened!"
request.each do |line|
	socket.puts line
	puts line
end
socket.puts "END"

sleep(0.5)

puts
puts "Now reading response:"
while line = socket.gets
	response << line.chomp
	puts line.chop
end
socket.close

code = response[0].split(' ')[1]

puts
case code
when '404' then puts "Error Occurred! Page Not Found"
end