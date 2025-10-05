@echo off
echo Starting Kafka Server...
cd C:\kafka_2.13-3.9.0
bin\windows\kafka-server-start.bat config\server.properties