#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>
#include <vector>

using namespace std;

vector<int> extractReport(const string &reportText) {
    istringstream rStream(reportText);
    vector<int> report;
    while (!rStream.eof()) {
        int level;
        rStream >> level;
        report.push_back(level);
    }
    return report;
}

bool isReportSafe(const vector<int> &report, int ignore) {
    int prev = (ignore == 0) ? report[1] : report[0];
    int curr = (ignore == 0 || ignore == 1) ? report[2] : report[1];
    const int length = report.size();
    const int polarity = curr - prev;
    if (abs(polarity) > 3) {
        return false;
    }
    for (int i = (ignore == 0 || ignore == 1) ? 3 : 2; i < length; i++) {
        if (i == ignore) continue;
        prev = curr;
        curr = report[i];
        const int diff = curr - prev;
        if (diff * polarity <= 0 || abs(diff) > 3) {
            return false;
        }
    }
    return true;
}

bool isReportTolerable(const string &reportText) {
    const vector<int> report = extractReport(reportText);
    const int length = report.size();
    for (int i = -1; i < length; i++) {
        if (isReportSafe(report, i)) {
            return true;
        };
    }
    return false;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        cerr << "No file included!" << endl;
        return 1;
    }
    ifstream infile;
    infile.open(argv[1]);
    int sum = 0;
    string reportText;
    while (getline(infile, reportText)) {
        sum += isReportTolerable(reportText);
    }
    cout << sum << endl;
    return 0;
}