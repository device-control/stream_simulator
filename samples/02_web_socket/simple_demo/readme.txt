Žg‚¢•ûF

- server
$ ruby websocket_server.rb

- client
$ pry -r ./websocket_client.rb
> $c0.open
> $c0.write "string"
> $c0.write_binary "binary"
> $c0.close
