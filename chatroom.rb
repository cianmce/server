require "pp"

class ChatRoom

  def initialize
    # ID of client that will join
    # @current_id = 0
    @clients = {}
    @rooms   = {}

  end

  def close
    @clients.each do |client_name, socket|
      puts "Closing socket for: '#{client_name}'"
      socket.shutdown(Socket::SHUT_WR)
      socket.close
      puts "Closed..."
    end
  end

  def remove_client(client_name)
    puts "removing client: '#{client_name}'"


    message = "#{client_name} has left the chatroom."
    @rooms.each do |room_ref, room|
      puts "ref: '#{room_ref}'"
      if room[:clients].include? client_name
        puts "has client!"
        message_chat_room(room_ref, message, client_name)
        remove_client_from_room(client_name, room_ref)
      end
    end


    socket = @clients.delete(client_name)
    unless socket.nil?
      # socket.close
    end
  end

  def message_chat_room(room_ref, message, client_name)
    # Sends message to every client in room

    puts "Sending to RM '#{room_ref}': '#{message}'"

    clients_in_room = @rooms[room_ref][:clients]
    clients_in_room.each do |client|
      socket = @clients[client]
      text = "CHAT:#{room_ref}
CLIENT_NAME:#{client_name}
MESSAGE:#{message}\n\n"
      puts "Sending to Client: #{client} '#{text}'"
      begin
        socket.puts text
      rescue Exception => e
        puts "Error senfing"
        puts e
      end
      puts "sent"
    end
    puts "ALL SENT!"
  end

  def get_client_id(client_name, client_socket)
    # Returns ID of client, ID is the client name
    # Adds if new client
    puts "Getting client_id for #{client_name}"
    unless @clients.include?(client_name)
      @clients[client_name] = client_socket
    end
    puts "returning: #{client_name.hash}"
    client_name.hash
  end

  def add_client_to_room(client_name, room_name, client_socket)
    puts "about to add client to room"
    room_ref = room_name.hash
    puts "adding client to room"
    client_id = get_client_id(client_name, client_socket)

    unless @rooms.include?(room_ref)
      @rooms[room_ref] = {
        :name => room_name,
        :clients => []
      }
    end
    puts "Checking if need to add to room"
    unless @rooms[room_ref][:clients].include?(client_name)
      @rooms[room_ref][:clients].push(client_name)
    end
    return {:room_ref => room_ref, :join_id => client_id}
  end

  def remove_client_from_room(client_name, room_ref)
    puts "Removing '#{client_name}' from '#{room_ref}'"

    # remove client if in the room
    puts @rooms[room_ref][:clients].delete(client_name)
    puts "Removed '#{client_name}':"
  end
end
