import std.algorithm;
import std.array;
import std.datetime;
import std.regex;
import std.stdio;

void main()
{
}

string[string] createDictionary(string dict)
{
    string[string] newDict;

    if (dict.length > 2)
    {
        foreach (s; dict[1..$-1].split("]["))
        {
            string[] parts = s.split(", ");
            newDict[parts[0].replace("\"", "")] = parts[1].replace("\"", "");
        }
    }

    return newDict;
}

unittest
{
    string[string] dict;
    assert(dict == createDictionary(""));
    assert(dict == createDictionary("[]"));

    dict["temp"] = "temporary";
    assert(dict == createDictionary("[\"temp\", \"temporary\"]"));

    dict["name"] = "John Doe";
    assert(dict == createDictionary("[\"temp\", \"temporary\"][\"name\", \"John Doe\""));
}

enum dictRegex = ctRegex!(r"(\$.+?\$)", "g");

string dreplace(string s, string[string] dict)
{
    if (s.length == 0) return "";

    string newString = s.idup;
    auto matches = match(s, dictRegex);

    foreach (currMatch; matches)
    {
        string[] m = currMatch.captures.array;
        foreach (c; m.sort.uniq())
        {
            newString = newString.replace(c, dict[c[1..$-1]]);
        }
    }

    return newString;
}

string dreplace2(string s, string[string] dict)
{
    if (s.length == 0) return "";

    auto newString = appender!(char[])();
    char[] capture;
    bool startCapture = false;
    for (int i = 0; i < s.length; i++)
    {
        if (startCapture && s[i] == '$')
        {
            foreach (c; dict[capture.idup])
            {
                newString.put(c);
            }
            capture.length = 0;
            startCapture = false;
        }
        else if (startCapture)
        {
            capture ~= s[i];
        }
        else if (s[i] == '$' && ((i-1) < 0 || s[i-1] == ' '))
        {
            startCapture = true;
        }
        else
        {
            newString.put(s[i]);
        }
    }

    return newString.data.idup;
}

static string[string] benchDict;

void bench1()
{
   dreplace("$temp$ here comes the name $name$", benchDict);
}

void bench2()
{
   dreplace2("$temp$ here comes the name $name$", benchDict);
}

unittest
{
    string[string] dict;
    assert("" == dreplace("", dict));
    assert("" == dreplace2("", dict));

    dict["temp"] = "temporary";
    assert("temp" == dreplace("temp", dict));
    assert("temporary" == dreplace("$temp$", dict));
    assert("temporary temporary" == dreplace("$temp$ $temp$", dict));
    assert("temp" == dreplace2("temp", dict));
    assert("temporary" == dreplace2("$temp$", dict));
    assert("temporary temporary" == dreplace2("$temp$ $temp$", dict));

    dict["name"] = "John Doe";
    assert("temporary here comes the name John Doe" ==
           dreplace("$temp$ here comes the name $name$", dict));
    assert("temporary here comes the name John Doe" ==
           dreplace2("$temp$ here comes the name $name$", dict));

    benchDict["temp"] = "temporary";
    benchDict["name"] = "John Doe";
    auto r = benchmark!(bench1, bench2)(1000);
    for (int i = 0; i < 2; i++)
    {
        writefln("Bench%d: %d", i+1, r[i].to!("usecs", int));
    }
}
