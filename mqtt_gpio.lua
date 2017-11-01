broker = "192.168.178.60"
port = "1883"
GPIO5 = 1  
GPIO4 = 2
gpio.mode(GPIO5,gpio.INPUT,gpio.PULLUP)
gpio.mode(GPIO4,gpio.OUTPUT,gpio.LOW)
clientId=node.chipid()
ID = 1
commandSubscribeTopic = "openhab/out/ESP"..clientId.."_GPIO5/state"
statePublishTopic = "openhab/in/ESP"..clientId.."_GPIO4/state" 
-- init mqtt client with keepalive timer 120sec
m = mqtt.Client(clientId, 120, "user", "pwd")
-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "offline", 0, 0)
m:on("connect", function(con) print ("connected") end)
m:on("offline", function(con) print ("offline") node.restart() end)

function connect()
     -- iot.eclipse.org
     -- broker.mqttdashboard.com
     -- subscribe topic with qos = 0
     m:connect(broker, port, 0, 
          function(conn) 
               print("connected") 
               publish()
               subscribe()
               start()
          end)
end

function subscribe()
     m:subscribe(commandSubscribeTopic,0, 
          function(conn)
          print("Subscribe topic " ..commandSubscribeTopic.. " success") 
            receive()
            end)
end   
                        
function publish()
     IN1 = gpio.read(GPIO5)
        if IN1 == 0 then
            IN1STATE = "OFF"
          else if IN1 == 1 then
            IN1STATE = "ON"
          end
        end
              
     msg = IN1STATE
          
     print (msg)
     m:publish(statePublishTopic,msg,0,0, function(conn) print("sent") end)
end

function receive()
    m:on("message", function(conn, topic, data)
                        print(topic .. ":" )
                            if data ~= nil
                            then
                                print(data)
                            end
                            if topic == commandSubscribeTopic 
                                then
                                    if data == "OFF" then
                                        gpio.write(GPIO4, gpio.LOW)
                                        print "Led Spento"
                
                                    elseif
                                        data == "ON" then
                                        gpio.write(GPIO4, gpio.HIGH)
                                        print "Led Acceso"
                                    else
                                        print "Evento non atteso"
                                    
                                    end
                            end
                    end)
end      
function start()
     tmr.alarm(1, 3000, 1, function() 
          if pcall(publish) then
              print("Send OK")
          else
              print("Send err" )
         end
         -- if pcall(receive) then
          --      print("Receive OK")
         -- else
          --      print("Receive KOOO")
         -- end      
     end)
end

connect()
