import std.stdio;

string buff = import("input");

void main()
{
    onlySanta();
    santaAndRobot();
}

void onlySanta()
{
    ulong buffLen = buff.length;
    ulong currX = buffLen / 2;
    ulong currY = currX;
    int[][] houses;
    houses.length = buffLen;
    for (int i = 0; i < buffLen; i++)
    {
        houses[i].length = buffLen;
    }

    houses[currX][currY]++;
    foreach (i, v; buff)
    {
        if (v == '^')
            currY++;
        else if(v == 'v')
            currY--;
        else if (v == '<')
            currX--;
        else if (v =='>')
            currX++;
        houses[currX][currY]++;
    }

    ulong houseCount;
    for (int i = 0; i < buffLen; i++)
    {
        for (int j = 0; j < buffLen; j++)
        {
            if (houses[i][j] > 0)
            {
                houseCount++;
            }
        }
    }
    writeln("Santa Num Houses: ", houseCount);
}

void santaAndRobot()
{
    ulong buffLen = buff.length;
    ulong santaX = buffLen / 2;
    ulong santaY = santaX;
    ulong robotX = santaX;
    ulong robotY = santaX;
    int[][] houses;
    houses.length = buffLen;
    for (int i = 0; i < buffLen; i++)
    {
        houses[i].length = buffLen;
    }

    houses[santaX][santaY]++;
    foreach (i, v; buff)
    {
        if (i % 2 == 0)
        {
            if (v == '^')
                santaY++;
            else if(v == 'v')
                santaY--;
            else if (v == '<')
                santaX--;
            else if (v =='>')
                santaX++;
            houses[santaX][santaY]++;
        }
        else
        {
            if (v == '^')
                robotY++;
            else if(v == 'v')
                robotY--;
            else if (v == '<')
                robotX--;
            else if (v =='>')
                robotX++;
            houses[robotX][robotY]++;
        }
    }

    ulong houseCount;
    for (int i = 0; i < buffLen; i++)
    {
        for (int j = 0; j < buffLen; j++)
        {
            if (houses[i][j] > 0)
            {
                houseCount++;
            }
        }
    }
    writeln("Santa and Robot Num Houses: ", houseCount);
}
