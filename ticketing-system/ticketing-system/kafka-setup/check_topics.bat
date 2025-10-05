@echo off
echo Checking Kafka topics...
cd C:\kafka_2.13-3.9.0
bin\windows\kafka-topics.bat --list --bootstrap-server localhost:9092
echo.
echo If you see the topic list above, topics were created successfully!
pause