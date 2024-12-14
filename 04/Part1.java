import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;

public class Part1 {
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
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                sum += countOk(x, y);
            }
        }
        System.out.println(sum);
    }

    private static int countOk(int x, int y) {
        char[][] sequences = getSequences(x, y);
        int sum = 0;
        for (char[] sequence : sequences) {
            if (isOk(sequence)) sum++;
        }
        return sum;
    }

    private static boolean isOk(char[] seq) {
        if (seq == null || seq.length != 4) return false;
        return (seq[0] == 'X' && seq[1] == 'M' && seq[2] == 'A' && seq[3] == 'S');
    }

    private static char[][] getSequences(int x, int y) {
        char[][] sequences = {
            getHorizontalLeftToRight(x, y),
            getHorizontalRightToLeft(x, y),
            getVerticalTopToBottom(x, y),
            getVerticalBottomToTop(x, y),
            getTopLeftToBottomRight(x, y),
            getTopRightToBottomLeft(x, y),
            getBottomLeftToTopRight(x, y),
            getBottomRightToTopLeft(x, y)
        };
        return sequences;
    }

    private static char[] getSequence(
        int x0, int y0,
        int x1, int y1,
        int x2, int y2,
        int x3, int y3
    ) {
        char[] seq = {
            crossword.get(y0).charAt(x0),
            crossword.get(y1).charAt(x1),
            crossword.get(y2).charAt(x2),
            crossword.get(y3).charAt(x3)
        };
        return seq;
    }

    private static char[] getHorizontalLeftToRight(int x, int y) {
        if (x > width-4) return null;
        return getSequence(
            x, y,
            x+1, y,
            x+2, y,
            x+3, y
        );
    }

    private static char[] getHorizontalRightToLeft(int x, int y) {
        if (x < 3) return null;
        return getSequence(
            x, y,
            x-1, y,
            x-2, y,
            x-3, y
        );
    }

    private static char[] getVerticalTopToBottom(int x, int y) {
        if (y > height-4) return null;
        return getSequence(
            x, y,
            x, y+1,
            x, y+2,
            x, y+3
        );
    }

    private static char[] getVerticalBottomToTop(int x, int y) {
        if (y < 3) return null;
        return getSequence(
            x, y,
            x, y-1,
            x, y-2,
            x, y-3
        );
    }

    private static char[] getTopLeftToBottomRight(int x, int y) {
        if (x > width-4 || y > height-4) return null;
        return getSequence(
            x, y,
            x+1, y+1,
            x+2, y+2,
            x+3, y+3
        );
    }

    private static char[] getTopRightToBottomLeft(int x, int y) {
        if (x < 3 || y > height-4) return null;
        return getSequence(
            x, y,
            x-1, y+1,
            x-2, y+2,
            x-3, y+3
        );
    }

    private static char[] getBottomLeftToTopRight(int x, int y) {
        if (x > width-4 || y < 3) return null;
        return getSequence(
            x, y,
            x+1, y-1,
            x+2, y-2,
            x+3, y-3
        );
    }

    private static char[] getBottomRightToTopLeft(int x, int y) {
        if (x < 3 || y < 3) return null;
        return getSequence(
            x, y,
            x-1, y-1,
            x-2, y-2,
            x-3, y-3
        );
    }
}