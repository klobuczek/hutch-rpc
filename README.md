# How to run:

    bundle 
    hutch --require api_v2_consumer.rb --mq-exchange ""

In a separate window:

    rvm use 3.1
    gem install bunny
    ruby api_client.rb

To test stomp client over websocket:

    open stomp_client.html