require 'unimidi'


@output = UniMIDI::Output.gets
@input = UniMIDI::Input.gets

loop do
  unless @input.buffer.empty?
    puts "Signal is: #{@input.buffer[0][:data][0]}"
    puts "Note number: #{@input.buffer[0][:data][1]}"
    puts "Voltage is: #{@input.buffer[0][:data][2]}"
    @input.buffer.clear
  end
end




