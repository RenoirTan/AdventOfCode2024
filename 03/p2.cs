using System;
using System.IO;
using System.Text.RegularExpressions;

class Part2 {
    static int Main(string[] args) {
        if (args.Length < 1) {
            Console.WriteLine("No file included!");
            return 1;
        }
        string program;
        using (StreamReader sr = File.OpenText(args[0])){
            program = sr.ReadToEnd();
        }
        Regex pattern = new Regex(@"(do\(\)|don't\(\)|mul\((\d+),(\d+)\))");
        MatchCollection matches = pattern.Matches(program);
        int sum = 0;
        bool enabled = true;
        foreach (Match match in matches) {
            if (match.Groups[0].Value == "do()") enabled = true;
            else if (match.Groups[0].Value == "don't()") enabled = false;
            else if (enabled) {
                int a = Int32.Parse(match.Groups[2].Value);
                int b = Int32.Parse(match.Groups[3].Value);
                sum += a * b;
            }
        }
        Console.WriteLine(sum);
        return 0;
    }
}