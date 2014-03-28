import std.algorithm : map, filter;
import std.array : split;
import std.conv : parse;
import std.stdio : writefln, File;
import std.string : isNumeric;
import diff;

void football()
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

void weather()
{
    Record!(uint) rec;
    File("weather.dat").byLine()
            .map!(a => a.split())
            .filter!(a => a.length >= 14)
            .filter!(a => isNumeric(a[0]))
            .map!(a => Record!(uint)(parse!uint(a[0]), parse!uint(a[1]), parse!uint(a[2])))
            .findMinDiff(rec);
    writefln("Day %d, spread %d", rec.id, rec.diff);
}

void main()
{
    writefln("Executing: Football");
    football;
    writefln("Executing: Weather");
    weather;
}
