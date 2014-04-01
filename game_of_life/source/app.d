import std.conv;
import std.exception;
import std.getopt;
import std.file;
import std.regex;
import std.stdio;

// Static regex created at compile-time.
enum dimRegex = ctRegex!(r"^(\d+)\s(\d+)$");

void main(string[] args)
{
    char[][] map;
    string filename;
    int generations = 5;

    getopt(
        args,
        "generations|g", &generations,
        "filename|f", &filename
    );
    enforce(exists(filename));

    foreach (line; File(filename).byLine)
    {
        auto m = match(line, dimRegex);
        if (!m)
        {
            map ~= line.dup;
        }
    }

    writeln("Generation 0:");
    foreach (line; map)
    {
        writeln(line);
    }

    foreach (int g; 1..generations)
    {
        map = updateMap(map);
        writefln("\nGeneration %d: ", g);
        foreach (line; map)
        {
            writeln(line);
        }
    }
}

char[][] updateMap(char[][] map)
{
    char[][] newMap = map.dup;
    int numLive;
    for (int i = 0; i < map.length; i++)
    {
        for (int j = 0; j < map[i].length; j++)
        {
            newMap[i][j] = '.';
            numLive = getNumLive(i, j, map);
            if (makeLive(map[i][j], numLive))
            {
                newMap[i][j] = '*';
            }
            else if (killOff(map[i][j], numLive))
            {
                newMap[i][j] = '.';
            }
        }
    }
    return newMap;
}

bool makeLive(char c, int num)
{
    return (c == '.' && num == 3) ||
           (c == '*' && (num == 2 || num == 3));
}

auto killOff = (char c, int num) => (c == '*' && (num > 3 || num < 2));

int getNumLive(int row, int col, char[][] map)
{
    int numLive;
    for (int i = row - 1; i <= row + 1; i++)
    {
        for (int j = col - 1; j <= col + 1; j++)
        {
            if (i < 0 || i >= map.length || j < 0 || j >= map[i].length || (i == row && j == col))
            {
                continue;
            }
            if (map[i][j] == '*')
            {
                numLive++;
            }
        }
    }

    return numLive;
}
