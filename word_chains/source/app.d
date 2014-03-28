import std.algorithm;
import std.array;
import std.exception;
import std.file;
import std.stdio;
import std.string;

void main(string[] args)
{
    if (args.length < 4)
    {
        writeln("Usage: word_chains <start> <end> <dict>");
    }
    else if (args[1].length != args[2].length)
    {
        writeln("Start and end words must be the same size.");
    }
    else
    {
        enforce(exists(args[3]));
        getChain(args[1], args[2], args[3]);
    }
}

void getChain(string start, string end, string dict)
{
    string[] wordChain;

    // Only look at words that are the same length as the start and end words.
    // Also, ignore words that have a single quote in them.  Lastly, make sure
    // it's all lower case.
    string[] words = File(dict).byLine()
                          .filter!(a => a.length == start.length)()
                          .filter!(a => std.string.indexOf(a, "'") == -1)()
                          .map!(a => a.idup.toLower)
                          .array;


    bool[string] prev;
    string[][] chains = getChains(prev, start, end, words, 1);
    /*writeln("Chains: ", chains);*/

    foreach (k, v; chains)
    {
        v = start ~ v;
        if (wordChain.length == 0 || wordChain.length > v.length)
        {
            wordChain = v;
        }
    }

    writeln("Word chain: ", wordChain);
}


string[][] getChains(in bool[string] prev, in string start, in string end,
                     in string[] words, in int depth)
{
    string[][] chains;
    int newDepth = depth + 1;
    /*writeln("Old Prev: ", prev);*/
    bool[string] newPrev = cast(bool[string])prev.dup;
    newPrev[start] = false;
    /*writeln("New Prev: ", newPrev);*/
    ulong endDiff = end.length - depth;

    // Only look at words that we haven't seen yet, are different from the
    // first word by one character, and are differnet from the end word by N
    // characters.  For example, if the length of the word is 4 and the depth
    // is 2, then we only want to look at words that differ from the end word
    // by 2 characters.  The last part is very important as it keeps us from
    // going down paths that take us down long chains for no good reason.
    auto newWords = words.
         filter!(a => a !in newPrev &&
                      a.wordDiff(start) == 1 &&
                      a.wordDiff(end) == endDiff).array;

    if (newWords.length == 0)
    {
        return chains;
    }

    if (newWords.length > 0 && newWords[0] == end)
    {
        chains ~= [end];
        return chains;
    }

    foreach (w; newWords)
    {
        foreach (arr; getChains(newPrev, w, end, words, newDepth))
        {
            /*writeln("New chain: ", arr);*/
            chains ~= w ~ arr;
        }
    }
    return chains;
}

pure int wordDiff(string word1, string word2)
{
    char[] w1 = word1.dup;
    char[] w2 = word2.dup;
    int numDiffs;
    for (int i = 0; i < w1.length; i++)
    {
        numDiffs = (w1[i] == w2[i]) ? numDiffs : numDiffs + 1;
    }
    return numDiffs;
}

unittest
{
    assert("cat".wordDiff("cot") == 1);
    assert(wordDiff("cat", "cot") == 1);
    assert(wordDiff("cot", "cog") == 1);
    assert(wordDiff("cog", "dog") == 1);
}
