require 'socket'
require 'json'
require 'erb'

def render(erb_template)
	erb_template.result(binding {yield})
end

server = TCPServer.open(2000)

loop do
	request = []
	response = []

	client = server.accept
	sleep(1)
	line = client.gets.chomp
	until line == 'END'
		request << line
		line = client.gets.chomp
	end

	case request[0].split(' ')[0]

	when "GET"
		begin
			f = File.open(request[0].split(' ')[1])
			response << 'HTTP/1.0 200 OK'
			content = f.read
			response << "Content-Length: #{content.length}"
			response << "\n"
			response << content
		rescue Exception => e
			response << 'HTTP/1.0 404 Not Found'
		end

	when "POST"
		params = JSON.parse(request.last)

		template_letter = File.read 'thanks.html'
		erb_template = ERB.new template_letter
		form_letter = render(erb_template) do 
			lis = params["viking"].keys.collect do |key|
				"<li>#{key}: #{params["viking"][key]}</li>"
			end
			string = ''
			lis.each_with_index do |li, i|
				string << "\t\t" unless i == 0
				string << li + "\n"
			end
			string
		end
		response << 'HTTP/1.0 200 OK'
		response << "Content-Length: #{form_letter.length}"
		response << "\n"
		response << form_letter
	end 


	response.each do |line|
		client.puts line
	end; client.puts

	client.puts Time.now.ctime
	client.puts 'See you later homeskillet!'
	sleep(1)
	client.close
end

