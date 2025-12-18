# Указываем компилятор и флаги
CXX = g++
# Добавляем -Iinclude, чтобы можно было писать #include "dbase/Schema.h"
CXXFLAGS = -std=c++17 -Wall -Wextra -Iinclude

# Имя исполнимого файла
TARGET = DBrun

# Где искать исходники
SRC_DIR = src

SOURCES = $(wildcard $(SRC_DIR)/*.cpp) \
          $(wildcard $(SRC_DIR)/db/*.cpp) \
          $(wildcard $(SRC_DIR)/ADT/*.cpp)

# Список объектных файлов (будут создаваться рядом с исходниками)
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
