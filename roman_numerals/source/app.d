import std.algorithm;
import std.array : array;
import std.regex : replace, regex, match;
import std.stdio;

void main()
{
}

pure nothrow int[char] getRomanDict()
{
    return ['I': 1, 'V': 5, 'X': 10, 'L': 50, 'C': 100, 'D': 500, 'M': 1000];
}

string fromNumber(int num)
{
    int[char] romanDict = getRomanDict();
    char[] result;

    foreach (v; sort!((a,b) => a > b)(romanDict.values))
    {
        int diff = num - v;
        if (diff < 0) continue;

        result ~= toRoman(v);
        num = diff;
        while (diff > 0 && diff >= v)
        {
            diff = num - v;
            result ~= toRoman(v);
            num = diff;
        }
    }
    string fixed = result.idup;
    fixed = replace(fixed, regex(`DCCCC`), "CM");
    fixed = replace(fixed, regex(`CCCC`), "CD");
    fixed = replace(fixed, regex(`LXXXX`), "XC");
    fixed = replace(fixed, regex(`XXXX`), "XL");
    fixed = replace(fixed, regex(`VIIII`), "IX");
    fixed = replace(fixed, regex(r"I{4}"), "IV");

    return fixed;
}

int fromRoman(string num)
{
    /*writeln("Num: ", num);*/
    int[char] dict = getRomanDict();
    int[] digits;
    foreach (c; num)
    {
        int temp = dict[c];
        if (digits.length > 0 && temp > digits[$-1])
        {
            digits[$-1] = temp - digits[$-1];
        }
        else
        {
            digits ~= temp;
        }
    }
    /*writeln("Digits: ", digits);*/
    return reduce!((a,b) => a + b)(digits);
}

unittest
{
    assert("I"       == fromNumber(1));
    assert("II"      == fromNumber(2));
    assert("III"     == fromNumber(3));
    assert("IV"      == fromNumber(4));
    assert("V"       == fromNumber(5));
    assert("VI"      == fromNumber(6));
    assert("VII"     == fromNumber(7));
    assert("VIII"    == fromNumber(8));
    assert("IX"      == fromNumber(9));
    assert("X"       == fromNumber(10));
    assert("XL"      == fromNumber(40));
    assert("L"       == fromNumber(50));
    assert("XC"      == fromNumber(90));
    assert("C"       == fromNumber(100));
    assert("CD"      == fromNumber(400));
    assert("D"       == fromNumber(500));
    assert("CM"      == fromNumber(900));
    assert("CMXCIX"  == fromNumber(999));
    assert("M"       == fromNumber(1000));
    assert("MCMXC"   == fromNumber(1990));
    assert("MCMXCIX" == fromNumber(1999));
    assert("MMVIII"  == fromNumber(2008));

    assert(fromRoman("I")       == 1);
    assert(fromRoman("II")      == 2);
    assert(fromRoman("III")     == 3);
    assert(fromRoman("IV")      == 4);
    assert(fromRoman("V")       == 5);
    assert(fromRoman("VI")      == 6);
    assert(fromRoman("VII")     == 7);
    assert(fromRoman("VIII")    == 8);
    assert(fromRoman("IX")      == 9);
    assert(fromRoman("X")       == 10);
    assert(fromRoman("XL")      == 40);
    assert(fromRoman("L")       == 50);
    assert(fromRoman("XC")      == 90);
    assert(fromRoman("C")       == 100);
    assert(fromRoman("CD")      == 400);
    assert(fromRoman("D")       == 500);
    assert(fromRoman("CM")      == 900);
    assert(fromRoman("CMXCIX")  == 999);
    assert(fromRoman("M")       == 1000);
    assert(fromRoman("MCMXC")   == 1990);
    assert(fromRoman("MCMXCIX") == 1999);
    assert(fromRoman("MMVIII")  == 2008);
}

char toRoman(int val)
{
    switch(val)
    {
        case 1000 : return 'M';
        case 500  : return 'D';
        case 100  : return 'C';
        case 50   : return 'L';
        case 10   : return 'X';
        case 5    : return 'V';
        case 1    : return 'I';
        default   : return 'A';
    }
}
