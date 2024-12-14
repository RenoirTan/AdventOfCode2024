using System;
using System.IO;
using System.Text.RegularExpressions;

class Part1 {
    static int Main(string[] args) {
        if (args.Length < 1) {
            Console.WriteLine("No file included!");
            return 1;
        }
        string program;
        using (StreamReader sr = File.OpenText(args[0])){
            program = sr.ReadToEnd();
        }
        Regex pattern = new Regex(@"mul\((\d+),(\d+)\)");
        MatchCollection matches = pattern.Matches(program);
        int sum = 0;
        foreach (Match match in matches) {
            int a = Int32.Parse(match.Groups[1].Value);
            int b = Int32.Parse(match.Groups[2].Value);
            sum += a * b;
        }
        Console.WriteLine(sum);
        return 0;
    }
}