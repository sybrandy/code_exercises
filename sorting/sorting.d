import std.algorithm;
import std.array;
import std.ascii;
import std.conv;
import std.stdio;
import std.string;

class Ball
{
    int val;
    Ball less;
    Ball more;

    this(int v)
    {
        this.val = v;
    }
}

struct Rack
{
    Ball root;

    void add(int val)
    {
        if (root is null)
        {
            root = new Ball(val);
        }
        else
        {
            addBall(root, new Ball(val));
        }
    }

    void addBall(ref Ball currBall, Ball newBall)
    {
        if (newBall.val <= currBall.val)
        {
            if (currBall.less is null)
            {
                currBall.less = newBall;
            }
            else
            {
                addBall(currBall.less, newBall);
            }
        }
        else
        {
            if (currBall.more is null)
            {
                currBall.more = newBall;
            }
            else
            {
                addBall(currBall.more, newBall);
            }
        }
    }

    @property int[] balls()
    {
        return traverse(root);
    }

    int[] traverse(Ball currBall)
    {
        if (currBall is null)
        {
            return [];
        }
        else
        {
            return traverse(currBall.less) ~
                   [currBall.val] ~
                   traverse(currBall.more);
        }
    }
}

string charSort(string input)
{
    char[] filtered = input.toLower.dup
                           .filter!(a => isAlpha(a))()
                           .array
                           .map!(a => to!char(a))
                           .array;
    char[] sorted;
    foreach (letter; 'a'..'z')
    {
        foreach (c; filtered)
        {
            if (letter == c)
            {
                sorted ~= c;
            }
        }
    }
    return sorted.idup;
}

void main()
{
    Rack r;
    int[] empty = [];
    assert(equal(empty, r.balls));
    r.add(20);
    assert(equal([20], r.balls));
    r.add(10);
    assert(equal([10, 20], r.balls));
    r.add(30);
    assert(equal([10, 20, 30], r.balls));
    assert(charSort("When not studying nuclear physics, Bambi likes to play beach volleyball.")
           == "aaaaabbbbcccdeeeeeghhhiiiiklllllllmnnnnooopprsssstttuuvwyyyy");
}
