#include <iostream>
#include <string>
#include <cstring>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

using namespace std;

int main() {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        cerr << "Socket creation failed" << endl;
        return 1;
    }

    //настройка адреса сервера для подключения
    sockaddr_in serverAddr{}; //cтруктура адреса сервера
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(7432);
    serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");

    if (connect(sock, (sockaddr*)&serverAddr, sizeof(serverAddr)) < 0) {
        cerr << "Connection failed" << endl;
        close(sock);
        return 1;
    }

    cout << "Connected to DB server on port 7432" << endl;
    cout << "Commands: SELECT, INSERT, DELETE, EXIT" << endl;

    string input;
    char buffer[4096]; //буфер для получения ответа от сервера

    while (true) {
        cout << "> "; 
        getline(cin, input);
        if (input.empty()) continue;
        input += "\n";  
        
        //отправка команд
        send(sock, input.c_str(), input.length(), 0);

        if (input == "EXIT\n" || input == "exit\n") {
            break;
        }
        //очистка буфера перед ответом
        memset(buffer, 0, sizeof(buffer));
        
        //ответ от сервера
        int bytesRead = recv(sock, buffer, sizeof(buffer) - 1, 0);
        
        if (bytesRead > 0) {
            cout << buffer;
        }
    }

    close(sock);
    return 0;
}
