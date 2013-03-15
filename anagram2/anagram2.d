import std.algorithm;
import std.array;
import std.exception;
import std.file;
import std.stdio;
import std.string : icmp, toLower;

immutable string currWord = "documenting";
static bool[char] wordDict;

void main(string[] args)
{
    enforce(exists(args[1]));
    immutable string currKey = currWord.dup.sort.idup;

    bool[string] dict;
    string[][string] anagrams;
    foreach (s; File(args[1]).byLine()
                             .filter!(a => a.length > 1)
                             .filter!(a => a.indexOf("'") < 0)
                             .map!(a => a.idup.toLower))
    {
        if (s !in dict)
        {
            dict[s] = true;
            string key = s.dup.sort.idup;
            anagrams[key] ~= s;
        }
    }

    foreach (c; currWord)
    {
        wordDict[c] = true;
    }

    for (int i = 2, j = currWord.length - 2; i <= j; i++, j--)
    {
        string[] shortAnagrams = anagrams.keys
                                         .filter!(a => a.length == i && all(a))
                                         .array;
        string[] longAnagrams = anagrams.keys
                                        .filter!(a => a.length == j && all(a))
                                        .array;

        if (shortAnagrams.length == 0 || longAnagrams.length == 0) continue;
        /*writeln("Short anagrams: ", shortAnagrams);*/
        /*writeln("Long anagrams: ", longAnagrams);*/

        foreach (shortString; shortAnagrams)
        {
            foreach (longString; longAnagrams)
            {
                foreach (sw; anagrams[shortString])
                {
                    foreach (lw; anagrams[longString])
                    {
                        if ((sw ~ lw).dup.sort.idup == currKey)
                        {
                            writefln("Words: %s, %s", sw, lw);
                        }
                    }
                }
            }
        }
    }
}

bool all(string a)
{
    auto res = a.map!(c => cast(char)c in wordDict)()
                .count!(a => !a)();
    return res == 0;
}
