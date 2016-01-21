import std.stdio, std.algorithm;

void main()
{
    /* auto floor = stdin.byLine.front.map!(a => (a == ')') ? -1 : (a == '(') ? 1 : 0).sum; */
    int floor = 0;
    ulong basementPos = 0;
    foreach (i, c; stdin.byLine.front)
    {
        floor += (c == ')') ? -1 : (c == '(') ? 1 : 0;
        if (basementPos == 0 && floor < 0)
        {
            basementPos = i + 1;
        }
    }
    writeln("Floor: ", floor);
    writeln("Basement position: ", basementPos);
}
