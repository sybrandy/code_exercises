import std.datetime;
import std.conv;
import std.stdio;

ulong value;

void main(string[] args)
{
    value = parse!ulong(args[1]);
    auto b = comparingBenchmark!(f1, f2, 100000);
    writeln(b.point);
}

void f1()
{
    ulong a = value >> 1;
}

void f2()
{
    ulong a = value / 2;
}
