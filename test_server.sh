#!/bin/bash

echo "=== Тест сетевого интерфейса СУБД ==="
echo ""
echo "Запуск сервера в фоновом режиме..."
./DBrun --server &
SERVER_PID=$!

sleep 2

echo ""
echo "Отправка тестовых запросов через netcat..."
echo ""

# Тест 1: INSERT
echo "1. INSERT запрос:"
echo "INSERT INTO Type VALUES ('Bus')" | nc localhost 7432
sleep 1

# Тест 2: SELECT
echo ""
echo "2. SELECT запрос:"
echo "SELECT Type.name FROM Type WHERE Type.name = 'Bus'" | nc localhost 7432
sleep 1

# Тест 3: EXIT
echo ""
echo "3. Завершение соединения:"
echo "EXIT" | nc localhost 7432

echo ""
echo "Остановка сервера..."
kill $SERVER_PID 2>/dev/null

echo "Тест завершен!"
