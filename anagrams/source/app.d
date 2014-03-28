import std.algorithm;
import std.exception;
import std.file;
import std.stdio;
import std.string : icmp, toLower, indexOf;

void main(string[] args)
{
    enforce(exists(args[1]));

    bool[string] dict;
    string[][string] anagrams;
    foreach (s; File(args[1]).byLine()
                             .filter!(a => a.length > 1)
                             .filter!(a => a.indexOf("'") < 0))
    {
        if (s.idup.toLower !in dict)
        {
            dict[s.idup.toLower] = true;
            string key = s.dup.sort.idup.toLower;
            anagrams[key] ~= s.idup;
        }
    }

    writeln("Number of words: ", dict.length);

    ulong longest;
    int numAnagrams;
    string[] longestVals;
    foreach (key, vals; anagrams)
    {
        if (vals.length > 1)
        {
            if (vals.length > longest)
            {
                longest = vals.length;
                longestVals = vals.dup;
            }
            numAnagrams += vals.length;
        }
    }
    writefln("Num Anagrams: %d, Longest: %d", numAnagrams, longest);
    writeln("Longest values: ", longestVals);
}
