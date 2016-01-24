import std.stdio, std.array, std.algorithm, std.regex;

string buff = import("input");

void main()
{
    auto parts = buff.split("\n");
    auto niceStrings = parts.filter!(hasVowels)
                            .filter!(hasDupeLetters)
                            .filter!(hasBadString)
                            .array;
    writeln("Nice strings (Rules 1): ", niceStrings.length);

    auto niceStrings2 = parts.filter!(hasPairs)
                             .filter!(hasTrips)
                             .array;
    writeln("Nice strings (Rules 2): ", niceStrings2.length);
}

bool hasVowels(string val)
{
    return 3 <= val.count!(isVowel);
}

bool isVowel(dchar c)
{
    return (c == 'a') || (c == 'e') || (c == 'i') || (c == 'o') || (c == 'u');
}

bool hasDupeLetters(string val)
{
    foreach (letter, count; val.group)
    {
        if (count >= 2)
            return true;
    }
    return false;
}

auto badStringPat = ctRegex!(`(?:ab|cd|pq|xy)`);
bool hasBadString(string val)
{
    auto m = match(val, badStringPat);
    return m.empty;
}

bool hasPairs(string val)
{
    if (val.length == 0) return false;
    char[2] currSlice;
    for (int i = 0; i < val.length - 3; i++)
    {
        currSlice[0] = val[i];
        currSlice[1] = val[i+1];
        if (val.count(currSlice.idup) > 1)
        {
            return true;
        }
    }
    return false;
}

bool hasTrips(string val)
{
    for (int i = 0; i < val.length - 2; i++)
    {
        if (val[i] == val[i+2])
        {
            return true;
        }
    }
    return false;
}
