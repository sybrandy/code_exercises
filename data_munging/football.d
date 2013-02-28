import std.algorithm : map, filter;
import std.array : split;
import std.conv : parse;
import std.stdio : writefln, File;
import std.string : isNumeric;
import diff;

void main()
{
    Record!(string) rec;
    File("football.dat").byLine()
            .map!(a => a.split())
            .filter!(a => a.length == 10)
            .filter!(a => isNumeric(a[0]))
            .map!(a => Record!(string)(a[1].idup, parse!int(a[6]), parse!int(a[8])))
            .findMinDiff(rec);
    writefln("Team %s, Spread %d", rec.id, rec.diff);
}
