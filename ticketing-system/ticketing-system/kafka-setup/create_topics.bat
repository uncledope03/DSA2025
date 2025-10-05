@echo off
echo Creating Kafka topics...
cd C:\kafka_2.13-3.9.0

echo Waiting 10 seconds for Kafka to start...
timeout /t 10 /nobreak

echo Creating topics...
bin\windows\kafka-topics.bat --create --topic ticket.requests --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
bin\windows\kafka-topics.bat --create --topic payments.processed --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
bin\windows\kafka-topics.bat --create --topic schedule.updates --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
bin\windows\kafka-topics.bat --create --topic notifications --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
bin\windows\kafka-topics.bat --create --topic ticket.validations --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

echo Kafka topics created successfully!
echo.
echo To verify, run: bin\windows\kafka-topics.bat --list --bootstrap-server localhost:9092
pause