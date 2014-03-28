import std.array;
import std.algorithm;
import std.exception;
import std.file;
import std.random;
import std.stdio;
import std.string;

void main(string[] args)
{
    enforce(exists(args[1]));
    string[][string] trigrams = getTrigrams(args[1]);
    genNewText(trigrams);
}

string[][string] getTrigrams(string fname)
{
    auto words = appender!(string[])();
    foreach (line; File(fname).byLine().map!(a => strip(a).idup)())
    {
        foreach (word; line.split())
        {
            words.put(word);
        }
    }

    string[] wordList = words.data;
    string[][string] trigrams;
    for (int i = 0; i < wordList.length - 2; i++)
    {
        string key = join(wordList[i..i+2], " ");
        trigrams[key] ~= wordList[i+2];
    }
    return trigrams;
}

void genNewText(string[][string] trigrams)
{
    string[] keyList = trigrams.keys;
    Mt19937 gen;
    gen.seed(unpredictableSeed);
    string currKey = keyList[uniform(0, keyList.length, gen)];

    string[] wordList = currKey.split();
    string nextWord = trigrams[currKey][uniform(0, trigrams[currKey].length, gen)];
    wordList ~= nextWord;

    currKey = join(wordList[$-2..$], " ");
    while(currKey in trigrams)
    {
        nextWord = trigrams[currKey][uniform(0, trigrams[currKey].length, gen)];
        wordList ~= nextWord;
        currKey = join(wordList[$-2..$], " ");
    }
    writeln("New string: ", join(wordList, " "));
}
