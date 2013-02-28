import std.algorithm : map, filter;
import std.array : split;
import std.conv : parse;
import std.regex : match, regex;
import std.stdio : writefln, File;
import diff;

auto numRegex = regex(`\d+`);

void main()
{
    Record!(uint) rec;
    File("weather.dat").byLine()
            .map!(a => a.split())
            .filter!(a => a.length >= 14)
            .filter!(a => !match(a[0], numRegex).empty)
            .map!(a => Record!(uint)(parse!uint(a[0]), parse!uint(a[1]), parse!uint(a[2])))
            .findMinDiff(rec);
    writefln("Day %d, spread %d", rec.id, rec.diff);
}
