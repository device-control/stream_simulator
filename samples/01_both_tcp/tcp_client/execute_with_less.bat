title tcp_client(+less)
touch stream_simulator.log
start less +F stream_simulator.log
pry -r "./execute_stream_simulator.rb"
