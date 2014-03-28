import std.conv;
import std.stdio;

void main(string[] args)
{
    genParens(parse!(int)(args[1]));
}

void genParens(int numParens)
{
    genParens(numParens, ['('], 1, 0);
}

void genParens(int numParens, char[] buff, int numOpen, int numClose)
{
    if (numParens == numClose)
    {
        writeln(buff);
    }
    else
    {
        if (numOpen != numParens)
        {
            genParens(numParens, buff ~ '(', numOpen + 1, numClose);
        }
        if (numClose < numOpen)
        {
            genParens(numParens, buff ~ ')', numOpen, numClose + 1);
        }
    }
}

/+
numParens = 4
(())(())
(((())))
((()()))
((())())
((()))()
(()(()))
(()()())
(()())()
(())()()
()((()))
()(()())
()(())()
()()(())
()()()()
+/
