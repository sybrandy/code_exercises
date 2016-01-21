import std.stdio, std.algorithm, std.array, std.conv;

void main()
{
    auto result = stdin.byLine
                       .map!(a => parseLine(a.idup))
                       .map!(a => calc(a));
    int totalPaper, totalRibbon;
    foreach (s; result)
    {
        totalPaper += s.paperArea;
        totalRibbon += s.ribbonLength;
    }
    writeln("Total area: ", totalPaper);
    writeln("Total ribbon: ", totalRibbon);
}

struct Dim
{
    int length, width, height;
}

Dim parseLine(string input)
{
    auto parts = split(input, 'x').map!(a => parse!int(a));
    Dim dimensions = {length: parts[0], width: parts[1], height: parts[2]};
    return dimensions;
}

struct Supply
{
    int paperArea, ribbonLength;
}

Supply calc(Dim d)
{
    int[] areas = [2 * d.length * d.width,
                   2 * d.width * d.height,
                   2 * d.height * d.length];
    auto sides = std.algorithm.sort([d.length, d.width, d.height]);
    Supply s =
    {
        paperArea: areas.sum + (areas.reduce!((a,b) => min(a,b)) / 2),
        ribbonLength: (sides[0] * 2) + (sides[1] * 2) + (d.length * d.width * d.height)
    };
    return s;
}
