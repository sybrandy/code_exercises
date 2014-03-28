import std.array;
import std.stdio;

void main()
{
}

string wrapper(string input, int col)
{
    char[] newString;
    newString.length = input.length;
    int newStart;
    int inStart;
    int diff;

    for (int end = col - 1; end < input.length;)
    {
        while (input[end] != ' ') { end--; }
        int lastChar = end;
        while (input[lastChar] == ' ') { lastChar--; }

        newString[newStart..(lastChar-diff+1)] = input.dup[inStart..lastChar+1];
        newString[(lastChar-diff+1)] = '\n';
        newStart = (lastChar-diff+2);
        inStart = end + 1;
        end = inStart + col;
        diff = inStart - newStart;
    }

    ulong remaining = input.length - inStart;
    newString[newStart..(newStart + remaining)] = input[inStart..$];
    return newString[0..($-diff)].idup;
}

unittest
{
    assert("A B\nC D\nE F" == wrapper("A B C D E F", 4));
    assert("A B\nC D E\nF" == wrapper("A B C D E F", 5));
    assert("A B\nC D\nE F" == wrapper("A B  C D  E F", 5));
}
