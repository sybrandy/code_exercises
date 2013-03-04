import std.algorithm;
import std.array;
import std.datetime;
import std.exception;
import std.file;
import std.stdio;
import std.string;

string fName;
void main(string[] args)
{
    enforce(exists(args[1]));
    fName = args[1];

    auto r = benchmark!(c1, c2, c3)(10);
    for (int i = 0; i < 3; i++)
    {
        writefln("Bench%d: %d", i+1, r[i].to!("msecs", int));
    }

    string[] list1 = concatReadable(fName);
    string[] list2 = concatFast(fName);
    string[] list3 = concatExt(fName, 6);

    if (equal(list1, list2))
    {
        writeln("Both lists are equal! (1 & 2)");
    }
    else
    {
        string[] diff = setDifference(list2, list1).array;
        writeln("Different: ", diff);
    }

    if (equal(list1, list3))
    {
        writeln("Both lists are equal! (1 & 3)");
    }
    else
    {
        string[] diff = setDifference(list3, list1).array;
        writeln("Different: ", diff);
    }
}

void c1()
{
    string[] list1 = concatReadable(fName);
    /*writeln("Length: ", list1.length);*/
}

void c2()
{
    string[] list1 = concatFast(fName);
    /*writeln("Length: ", list1.length);*/
}

void c3()
{
    string[] list1 = concatExt(fName, 6);
    /*writeln("Length: ", list1.length);*/
}

string[] concatReadable(string fname)
{
    bool[string] sixWords;
    bool[string] wordParts;

    foreach (s; File(fname).byLine)
    {
        if (s.length == 6)
        {
            sixWords[s.idup.toLower] = false;
        }
        else if (s.length >= 2 && s.length <= 4)
        {
            wordParts[s.idup.toLower] = false;
        }
    }

    string[] wordList;
    foreach (part1, val1; wordParts)
    {
        foreach (part2, val2; wordParts)
        {
            string newWord = part1 ~ part2;
            if (newWord.length == 6 && newWord in sixWords)
            {
                wordList ~= newWord;
            }
        }
    }
    return wordList.sort.uniq.array;
}

string[] concatFast(string fname)
{
    bool[string] sixWords;
    bool[string] twoWords;
    bool[string] threeWords;
    bool[string] fourWords;

    /*
    foreach (s; File(fname).byLine()
                           .filter!(a => a.length != 5 && a.length <= 6 && a.length >= 2)
                           .map!(a => a.idup.toLower))
    */
    foreach (s; File(fname).byLine)
    {
        switch (s.length)
        {
            case 2 : twoWords[s.idup.toLower] = false;
                     break;
            case 3 : threeWords[s.idup.toLower] = false;
                     break;
            case 4 : fourWords[s.idup.toLower] = false;
                     break;
            case 6 : sixWords[s.idup.toLower] = false;
                     break;
            default : break;
        }
    }

    string[] wordList;
    auto app = appender(wordList);
    foreach (part1, val1; threeWords)
    {
        foreach (part2, val2; threeWords)
        {
            string newWord = part1 ~ part2;
            if (newWord in sixWords)
            {
                app.put(newWord);
            }
        }
    }
    foreach (part1, val1; twoWords)
    {
        foreach (part2, val2; fourWords)
        {
            string newWord1 = part1 ~ part2;
            string newWord2 = part2 ~ part1;
            if (newWord1 in sixWords || newWord2 in sixWords)
            {
                if (newWord1 in sixWords)
                {
                    app.put(newWord1);
                }
                if (newWord2 in sixWords)
                {
                    app.put(newWord2);
                }
            }
        }
    }
    return app.data.sort.uniq.array;
}

string[] concatExt(string fname, uint wordSize)
{
    bool[string] words;
    bool[string] wordParts;
    uint minSize = 2;
    uint maxSize = wordSize - 2;

    foreach (s; File(fname).byLine()
                           .filter!(a => (a.length >= minSize && a.length <= maxSize) || a.length == wordSize)
                           .map!(a => a.idup.toLower))
    {
        if (s.length == wordSize)
        {
            words[s] = false;
        }
        else
        {
            wordParts[s] = false;
        }
    }

    auto newWords = appender!(string[])();
    foreach (part1, val1; wordParts)
    {
        foreach (part2, val2; wordParts)
        {
            string newWord1 = part1 ~ part2;
            string newWord2 = part2 ~ part1;
            if (newWord1 in words && newWord2 in words)
            {
                if (newWord1 in words)
                {
                    newWords.put(newWord1);
                }
                if (newWord2 in words)
                {
                    newWords.put(newWord2);
                }
            }
        }
    }

    return newWords.data.sort.uniq.array;
}
