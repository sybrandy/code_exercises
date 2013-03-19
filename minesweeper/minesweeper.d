import std.exception;
import std.file;
import std.math;
import std.regex;
import std.stdio;

// Static regex created at compile-time.
enum dimRegex = ctRegex!(r"^(\d+)\s(\d+)$");

void main(string[] args)
{
    char[][] map;
    enforce(exists(args[1]));
    int fieldNum;
    foreach (line; File(args[1]).byLine)
    {
        auto m = match(line, dimRegex);
        if (m && map.length > 0)
        {
            processMap(map, ++fieldNum);
        }

        if (m)
        {
            auto captures = m.captures;
            map.length = 0;
        }
        else
        {
            map ~= line.dup;
        }
    }
}

void processMap(char[][] map, int fieldNum)
{
    writeln("Field #", fieldNum);
    writeln("Map: ", map);

    for (int i = 0; i < map.length; i++)
    {
        for (int j = 0; j < map[i].length; j++)
        {
            if (map[i][j] == '*')
            {
                write('*');
            }
            else
            {
                write(countAdjacent(i, j, map));
            }
        }
        writeln();
    }
    writeln();
}

int countAdjacent(int row, int col, char[][] map)
{
    int count;

    for (int i = 0; i < map.length; i++)
    {
        for (int j = 0; j < map[i].length; j++)
        {
            if (map[i][j] == '*' &&
                abs(i - row) <= 1 &&
                abs(j - col) <= 1)
            {
                count++;
            }
        }
    }

    return count;
}
