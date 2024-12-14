import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;

public class Part2 {
    private static int width = 0;
    private static int height = 0;
    private static ArrayList<String> crossword;

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.out.println("No file included!");
            System.exit(1);
        }
        FileReader fr = new FileReader(args[0]);
        BufferedReader br = new BufferedReader(fr);
        String line = null;
        crossword = new ArrayList<String>();
        while ((line = br.readLine()) != null) {
            crossword.add(line);
        }
        width = crossword.get(0).length();
        height = crossword.size();
        int sum = 0;
        for (int x = 1; x < width-1; x++) {
            for (int y = 1; y < height-1; y++) {
                sum += isXmas(x, y);
            }
        }
        System.out.println(sum);
    }

    private static int isXmas(int x, int y) {
        if (isMas(getTopLeftToBottomRight(x, y)) && isMas(getTopRightToBottomLeft(x, y))) {
            return 1;
        } else {
            return 0;
        }
    }

    private static boolean isMas(char[] sequence) {
        return (
            sequence[1] == 'A' &&
            (
                (sequence[0] == 'M' && sequence[2] == 'S') ||
                (sequence[0] == 'S' && sequence[2] == 'M')
            )
        );
    }

    private static char[] getTopLeftToBottomRight(int x, int y) {
        char[] sequence = {
            crossword.get(y-1).charAt(x-1),
            crossword.get(y).charAt(x),
            crossword.get(y+1).charAt(x+1)
        };
        return sequence;
    }

    private static char[] getTopRightToBottomLeft(int x, int y) {
        char[] sequence = {
            crossword.get(y+1).charAt(x-1),
            crossword.get(y).charAt(x),
            crossword.get(y-1).charAt(x+1)
        };
        return sequence;
    }
}