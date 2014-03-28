import std.exception;
import std.file;
import std.regex;
import std.stdio;

// Static regex created at compile-time.
enum dimRegex = ctRegex!(r"^(\d+)\s(\d+)$");

void main(string[] args)
{
    char[][] map;
    enforce(exists(args[1]));

    foreach (line; File(args[1]).byLine)
    {
        auto m = match(line, dimRegex);
        if (!m)
        {
            map ~= line.dup;
        }
    }

    char[][] newMap = updateMap(map);

    // Output the new map.
    writeln("Prev. Generation: ");
    foreach (line; map)
    {
        writeln(line);
    }

    writeln("\nNew Generation: ");
    foreach (line; newMap)
    {
        writeln(line);
    }
}

char[][] updateMap(char[][] map)
{
    char[][] newMap;
    int numLive;
    newMap.length = map.length;
    for (int i = 0; i < map.length; i++)
    {
        newMap[i].length = map[i].length;
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
