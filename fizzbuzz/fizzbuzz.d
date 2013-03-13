import std.algorithm;
import std.conv;
import std.stdio;

void main()
{
    foreach (i; 1..101)
    {
        writeln((isFizz(i) && isBuzz(i)) ? "FizzBuzz"
                                         : isFizz(i) ? "Fizz"
                                                     : isBuzz(i) ? "Buzz"
                                                                 : text(i));
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
