#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>

using namespace std;

bool isReportSafe(const string &report) {
    int prev = 0;
    int curr = 0;
    istringstream rStream(report);
    rStream >> prev;
    rStream >> curr;
    const int polarity = curr - prev;
    if (abs(polarity) > 3) return false;
    while (!rStream.eof()) {
        prev = curr;
        rStream >> curr;
        const int diff = curr - prev;
        if (
            diff * polarity <= 0 || // not strictly increasing or decreasing
            abs(diff) > 3
        ) {
            return false;
        }
    }
    return true;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        cerr << "No file included!" << endl;
        return 1;
    }
    ifstream infile;
    infile.open(argv[1]);
    int sum = 0;
    string report;
    while (getline(infile, report)) {
        sum += isReportSafe(report);
    }
    cout << sum << endl;
    return 0;
}