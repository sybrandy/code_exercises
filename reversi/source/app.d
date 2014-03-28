import std.exception;
import std.file;
import std.stdio;

void main(string[] args)
{
    char[][] map;
    enforce(exists(args[1]));
    char player;

    foreach (line; File(args[1]).byLine)
    {
        if (line.length > 1)
        {
            map ~= line.dup;
        }
        else
        {
            player = line[0];
        }
    }

    // Determine next moves.
    for (int i = 0; i < map.length; i++)
    {
        for (int j = 0; j < map[i].length; j++)
        {
            if (map[i][j] != '.' && map[i][j] != 'O' && player != map[i][j])
            {
                if ((i - 1) >= 0 && map[i-1][j] == '.')
                {
                    map[i-1][j] = 'O';
                }
                if ((j - 1) >= 0 && map[i][j-1] == '.')
                {
                    map[i][j-1] = 'O';
                }
                if ((i + 1) < map.length && map[i+1][j] == '.')
                {
                    map[i+1][j] = 'O';
                }
                if ((j + 1) < map[i].length && map[i][j+1] == '.')
                {
                    map[i][j+1] = 'O';
                }
            }
        }
    }

    // Output the new map.
    foreach (line; map)
    {
        writeln(line);
    }
    writeln(player);
}
