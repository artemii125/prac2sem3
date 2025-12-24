# Kомпилятор и флаги
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Iinclude -pthread

# Имя исполнимого файла
TARGET = DBrun

# Исходники
SRC_DIR = src

SOURCES = $(wildcard $(SRC_DIR)/*.cpp) \
          $(wildcard $(SRC_DIR)/db/*.cpp) \
          $(wildcard $(SRC_DIR)/ADT/*.cpp)

# Список объектных файлов
OBJECTS = $(SOURCES:.cpp=.o)

# Правило сборки итогового файла
$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $@ $^

# Правило компиляции каждого файла
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Очистка
clean:
	rm -f $(OBJECTS) $(TARGET)

# Запуск по умолчанию
all: $(TARGET)
