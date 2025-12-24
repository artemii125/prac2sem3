# Сетевой интерфейс для СУБД

## Описание
Реализован сетевой интерфейс для СУБД из практики 1. Сервер слушает TCP соединения на порту 7432 и обрабатывает SQL-запросы в отдельных потоках с использованием мьютексов для защиты от конкурентного доступа к БД.

**Важно:** 
- SELECT запросы требуют обязательного указания условия WHERE
- Использование `SELECT *` запрещено - нужно явно указывать колонки

## Сборка
```bash
make clean
make
g++ -std=c++17 -o client client.cpp
```

## Запуск

### Режим сервера
```bash
./DBrun --server
```
Сервер запустится и будет ожидать подключений на порту 7432.

### Режим клиента (в другом терминале)
```bash
./client
```
Клиент подключится к серверу и позволит отправлять SQL-запросы.

### Локальный режим (без сети)
```bash
./DBrun
```
Запуск БД в интерактивном режиме без сетевого интерфейса.

### Тестирование с помощью netcat
```bash
echo "SELECT Type.name FROM Type WHERE Type.name = 'Bus'" | nc localhost 7432
```

### Автоматический тест
```bash
./test_server.sh
```

## Примеры использования

После подключения клиента можно выполнять SQL-запросы:

```sql
-- Вставка данных
INSERT INTO Type VALUES ('Bus')
INSERT INTO System VALUES ('1', '42', 'Center-Airport')

-- Выборка данных (WHERE обязателен, * запрещен!)
SELECT Type.name FROM Type WHERE Type.name = 'Bus'
SELECT System.route FROM System WHERE System.route = 'Center-Airport'
SELECT System.number, System.route FROM System WHERE System.number = '42'

-- Удаление данных
DELETE FROM Type WHERE Type.name = 'Bus'

-- Выход
EXIT
```

## Архитектура

### Компоненты

- **Server.h/cpp** - TCP сервер с многопоточной обработкой клиентов
  - Создает socket и слушает порт 7432
  - Для каждого клиента создает отдельный поток
  - Использует mutex для синхронизации доступа к БД
  
- **main.cpp** - точка входа с поддержкой режима сервера
  - `./DBrun` - локальный режим
  - `./DBrun --server` - сетевой режим
  
- **client.cpp** - простой TCP клиент для тестирования
  - Подключается к localhost:7432
  - Отправляет запросы и выводит результаты

### Многопоточность и синхронизация

```cpp
void Server::handleClient(int clientSocket) {
    // Каждый клиент обрабатывается в отдельном потоке
    while (true) {
        // Получение запроса от клиента
        string query = receiveQuery(clientSocket);
        
        // Критическая секция - доступ к БД
        {
            lock_guard<mutex> lock(dbMutex);
            db->query(query);  // Только один поток может выполнять запрос
        }
        
        // Отправка результата клиенту
        sendResponse(clientSocket, result);
    }
}
```

## Особенности реализации

1. Многопоточность: Каждый клиент обрабатывается в отдельном потоке (detached thread)
2. Синхронизация: std::mutex защищает БД от одновременного доступа
3. Множественные подключения: Сервер поддерживает неограниченное количество клиентов


# процесс взаимодействия
1. Клиент подключается к серверу по TCP
2. Клиент отправляет SQL-запрос (строка, завершающаяся \n)
3. Сервер обрабатывает запрос в отдельном потоке
4. Сервер отправляет результат обратно клиенту
5. Соединение остается открытым для следующих запросов
6. При команде EXIT соединение закрывается

# тестирование

# Одиночный клиент
# Терминал 1
./DBrun --server
# Терминал 2
./client
INSERT INTO Type VALUES ('Bus')
SELECT Type.name FROM Type WHERE Type.name = 'Bus'
EXIT


# Множественные клиент
# Терминал 1
./DBrun --server
# Терминал 2 (одноврем с 3)
./client
INSERT INTO Type VALUES ('Bus')
# Терминал 3
./client
SELECT Type.name FROM Type WHERE Type.name = 'Bus'


# Netcat
# Терминал 1
./DBrun --server
# Терминал 2
echo "SELECT Type.name FROM Type WHERE Type.name = 'Bus'" | nc localhost 7432
```

