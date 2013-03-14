import std.algorithm;
import std.conv;
import std.datetime;
import std.range;
import std.stdio;

void main()
{
    string[100] fb1;
    foreach (i; 1..101)
    {
        // This logic can be put into a simple function to make the loop
        // cleaner.
        fb1[i-1] =(isFizz(i) && isBuzz(i)) ? "FizzBuzz"
                                           : isFizz(i) ? "Fizz"
                                                       : isBuzz(i) ? "Buzz"
                                                                   : text(i);
    }
    writeln(fb1);

    // OO Approach.
    string[100] fb2;
    foreach (i; 1..101)
    {
        FB temp = fbFactory(i);
        fb2[i-1] = temp.val;
    }
    writeln(fb2);

    writeln("FB1 and FB2 the same: ", equal(fb1.dup, fb2.dup));

    string[] fb3;
    FBRange range = FBRange(1, 101);
    assert(isInputRange!(FBRange));
    foreach (i; range)
    {
        fb3 ~= i;
    }
    writeln(fb3);

    writeln("FB1 and FB3 the same: ", equal(fb1.dup, fb3.dup));

    auto r = benchmark!(bench1, bench2, bench3)(10000);
    for (int i = 0; i < 3; i++)
    {
        writefln("Bench%d: %d", i+1, r[i].to!("usecs", int));
    }
}

void bench1()
{
    string[100] fb1;
    foreach (i; 1..101)
    {
        // This logic can be put into a simple function to make the loop
        // cleaner.
        fb1[i-1] =(isFizz(i) && isBuzz(i)) ? "FizzBuzz"
                                           : isFizz(i) ? "Fizz"
                                                       : isBuzz(i) ? "Buzz"
                                                                   : text(i);
    }
}

void bench2()
{
    string[100] fb2;
    foreach (i; 1..101)
    {
        FB temp = fbFactory(i);
        fb2[i-1] = temp.val;
    }
}

void bench3()
{
    string[] fb3;
    FBRange range = FBRange(1, 101);
    foreach (i; range)
    {
        fb3 ~= i;
    }
}

auto isFizz = (int a) => (a % 3 == 0) || (text(a).count("3") > 0);
auto isBuzz = (int a) => (a % 5 == 0) || (text(a).count("5") > 0);

unittest
{
    assert(isFizz(1) == false);
    assert(isFizz(2) == false);
    assert(isFizz(3) == true);
    assert(isFizz(4) == false);
    assert(isFizz(5) == false);
    assert(isFizz(6) == true);
    assert(isFizz(7) == false);
    assert(isFizz(8) == false);
    assert(isFizz(9) == true);
    assert(isFizz(10) == false);
    assert(isFizz(11) == false);
    assert(isFizz(12) == true);
    assert(isFizz(13) == true);
    assert(isFizz(14) == false);
    assert(isFizz(15) == true);
    assert(isBuzz(1) == false);
    assert(isBuzz(2) == false);
    assert(isBuzz(3) == false);
    assert(isBuzz(4) == false);
    assert(isBuzz(5) == true);
    assert(isBuzz(6) == false);
    assert(isBuzz(7) == false);
    assert(isBuzz(8) == false);
    assert(isBuzz(9) == false);
    assert(isBuzz(10) == true);
    assert(isBuzz(11) == false);
    assert(isBuzz(12) == false);
    assert(isBuzz(13) == false);
    assert(isBuzz(14) == false);
    assert(isBuzz(15) == true);
    assert(isBuzz(51) == true);
}

class FB
{
    string val;
    
    this(int intVal)
    {
        val = text(intVal);
    }

    this(string strVal)
    {
        val = strVal;
    }
}

class Fizz : FB
{
    this()
    {
        super("Fizz");
    }
}

class Buzz : FB
{
    this()
    {
        super("Buzz");
    }
}

class FizzBuzz : FB
{
    this()
    {
        super("FizzBuzz");
    }
}

FB fbFactory(int val)
{
    if (val.isFizz() && val.isBuzz())
    {
        return new FizzBuzz();
    }
    else if (val.isFizz())
    {
        return new Fizz();
    }
    else if (val.isBuzz())
    {
        return new Buzz();
    }
    return new FB(val);
}

struct FBRange
{
    int endVal;
    int val;

    string front()
    {
        return (isFizz(val) && isBuzz(val)) ? "FizzBuzz"
                                            : isFizz(val) ? "Fizz"
                                                          : isBuzz(val) ? "Buzz"
                                                                        : text(val);
    }

    void popFront()
    {
        val++;
    }

    bool empty()
    {
        return !(val < endVal);
    }

    this(int start, int end)
    {
        val = start;
        endVal = end;
    }
}
