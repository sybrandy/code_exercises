import std.array;
import std.algorithm : map, reduce;
import std.conv;
import std.range;
import std.stdio;
import std.string : indexOf;

int add(string values)
{
    string delim = ",";
    if (values.indexOf("//") == 0)
    {
        delim = values[2..values.indexOf("\n")];
        values = values[values.indexOf("\n")+1..$];
    }
    /*writeln("values: ", values);*/
    /*writeln("Delimiter: ", delim);*/
    int[] vals = values.replace("\n", delim)
                       .split(delim)
                       .map!(a => parse!int(a))
                       .array;
    int[] negVals;
    foreach (int val; vals)
    {
        if (val < 0)
        {
            negVals ~= val;
        }
    }
    if (!negVals.empty)
    {
        throw new Exception("Negative values are not allowed: " ~
                            negVals.map!(a => to!(string)(a)).join(","));
    }
    return reduce!((a,b) => a + b)(0, vals);
}

unittest
{
    assert(add("1") == 1);
    assert(add("1,2") == 3);
    assert(add("5,7,10,3") == 25);
    assert(add("1\n2,3") == 6);
    assert(add("//;\n1;2") == 3);
    assert(add("//;\n1;2\n3;1") == 7);
    assert(add("//***\n1***2***3\n2***2") == 10);
    bool exp = false;
    try
    {
        int foo = add("-1,-2,-3");
    }
    catch (Exception e)
    {
        writeln("Errors: ", e.msg);
        exp = true;
    }
    assert(exp);

    exp = false;
    try
    {
        int foo = add("1,-2,3");
    }
    catch (Exception e)
    {
        writeln("Errors: ", e.msg);
        exp = true;
    }
    assert(exp);
}

void main()
{
}
