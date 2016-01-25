import std.stdio, std.array, std.algorithm, std.conv;

string buff = import("input");

void main()
{
    ubyte[1000][1000] grid;
    foreach (i, v; buff.split("\n"))
    {
        auto parts = v.split;
        if (parts.length == 0) continue;
        if (parts[0] == "toggle")
        {
            toggle(grid, parts[1], parts[3]);
        }
        else if (parts[1] == "on")
        {
            turnOn(grid, parts[2], parts[4]);
        }
        else if (parts[1] == "off")
        {
            turnOff(grid, parts[2], parts[4]);
        }
    }

    countLights(grid);
}

void countLights(ubyte[1000][1000] grid)
{
    int count;
    foreach (i; 0..1000)
    {
        foreach (j; 0..1000)
        {
            // Part 1 version.
            /* if (grid[j][i] == 1) */
            /*     count++; */
            // Part 2 version
            count += grid[j][i];
        }
    }
    writeln("Num lights: ", count);
}

int[] splitInts(string val)
{
    return val.split(",").map!(a => parse!int(a)).array;
}

void toggle(ref ubyte[1000][1000] grid, string start, string finish)
{
    auto startIndices = splitInts(start);
    auto endIndices = splitInts(finish);

    foreach (i; startIndices[0]..endIndices[0]+1)
    {
        foreach (j; startIndices[1]..endIndices[1]+1)
        {
            // Part 1 version.
            /* grid[j][i] ^= 1; */
            // Part 2 version
            grid[j][i] += 2;
        }
    }
}

void turnOn(ref ubyte[1000][1000] grid, string start, string finish)
{
    auto startIndices = splitInts(start);
    auto endIndices = splitInts(finish);

    foreach (i; startIndices[0]..endIndices[0]+1)
    {
        foreach (j; startIndices[1]..endIndices[1]+1)
        {
            // Part 1 version
            /* grid[j][i] = 1; */
            // Part 2 version
            grid[j][i]++;
        }
    }
}

void turnOff(ref ubyte[1000][1000] grid, string start, string finish)
{
    auto startIndices = splitInts(start);
    auto endIndices = splitInts(finish);

    foreach (i; startIndices[0]..endIndices[0]+1)
    {
        foreach (j; startIndices[1]..endIndices[1]+1)
        {
            // Part 1 version.
            /* grid[j][i] = 0; */
            // Part 2 version.
            if (grid[j][i] > 0)
                grid[j][i]--;
        }
    }
}
