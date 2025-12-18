#include <iostream>
#include <string>
#include "../include/dbase/dataBase.h"

using namespace std;

int main() {
    Database db;
    
    db.init("schema.json");

    cout << "--- Custom DB Started ---" << endl;
    cout << "Commands: SELECT, INSERT, DELETE, EXIT" << endl;

    string input;
    while (true) {
        cout << "> ";
        getline(cin, input);

        if (input == "EXIT" || input == "exit") {
            break;
        }

        if (input.empty()) continue;

        db.query(input);
    }

    return 0;
}