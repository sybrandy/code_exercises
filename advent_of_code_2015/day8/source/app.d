import std.conv, std.stdio, std.array, std.algorithm;

string buff = import("input");
string sample = q"EOS
""
"abc"
"aaa\"aaa"
"\x27"
EOS";

void main()
{
    /* auto charCodes = sample.split("\n") */
    /*                        .filter!(a => a != "") */
    /*                        .map!(a => a.length).sum; */
    /* auto chars = sample.split("\n") */
    /*                    .filter!(a => a != "") */
    /*                    .map!(a => a.parseString.length).sum; */
    /* auto encoded = sample.split("\n") */
    /*                .filter!(a => a != "") */
    /*                .map!(a => a.encodeString.length).sum; */
    auto charCodes = buff.split("\n")
                           .filter!(a => a != "")
                           .map!(a => a.length).sum;
    auto chars = buff.split("\n")
                       .filter!(a => a != "")
                       .map!(a => a.parseString.length).sum;
    auto encoded = buff.split("\n")
                   .filter!(a => a != "")
                   .map!(a => a.encodeString.length).sum;
    writeln(charCodes);
    writeln(chars);
    writeln(encoded);
    writeln("Part 1 result: ", charCodes - chars);
    writeln("Part 2 result: ", encoded - charCodes);
}

string encodeString(string input)
{
    char[] temp;
    temp ~= '"';
    foreach (i, v; input.dup)
    {
        if (v == '\\' || v == '"')
            temp ~= '\\';
        temp ~= v;
    }
    temp ~= '"';
    return temp.idup;
}

string parseString(string input)
{
    char[] temp;
    ulong lastChar = input.length - 1;
    bool hasEscape;
    bool hasCharCode;
    char[] charCode;

    foreach (i, v; input.dup)
    {
        if (i == 0 || i == lastChar)
        {
            continue;
        }
        else if (hasEscape && (v == '"' || v == '\\'))
        {
            temp ~= v;
            hasEscape = false;
        }
        else if (hasCharCode && charCode.length == 0)
        {
            charCode ~= v;
        }
        else if (hasCharCode && charCode.length == 1)
        {
            charCode ~= v;
            temp ~= parse!ubyte(charCode, 16);
            charCode.length = 0;
            hasCharCode = false;
            hasEscape = false;
        }
        else if (hasEscape && v == 'x')
        {
            hasCharCode = true;
        }
        else if (v == '\\')
        {
            hasEscape = true;
        }
        else
        {
            temp ~= v;
        }
    }
    return temp.idup;
}
