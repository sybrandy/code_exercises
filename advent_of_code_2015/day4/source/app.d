import std.stdio, std.digest.md, std.algorithm, std.conv;

void main()
{
    string key = "ckczppom";
    ulong counter;
    for (counter = 0; counter < ulong.max; counter++)
    {
        string temp = key ~ text(counter);
        if (hexDigest!MD5(temp).idup.startsWith("00000"))
        {
            break;
        }
    }
    writeln("Five Zeros: ", counter);

    for (counter = 0; counter < ulong.max; counter++)
    {
        string temp = key ~ text(counter);
        if (hexDigest!MD5(temp).idup.startsWith("000000"))
        {
            break;
        }
    }
    writeln("Six Zeros: ", counter);
}
