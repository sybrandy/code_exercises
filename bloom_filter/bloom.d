import std.algorithm;
import std.bitmanip;
import std.digest.md;
import std.exception;
import std.file;
import std.stdio;

void main(string[] args)
{
    enforce(exists(args[1]));

    size_t wc = reduce!((a, b) => a + b)(0, File(args[1]).byLine().filter!(a => a != "").map!(a => 1));
    writeln("Word count: ", wc);

    int size = 1;
    while (true)
    {
        if ((2 ^^ size) > wc)
        {
            break;
        }
        size++;
    }
    size++;
    size++;
    size++;
    writeln("Size: ", size);

    BitArray index;
    index.length = (2 ^^ size) - 1;
    writeln("Length: ", index.length);
    writeln("Words: ", index.dim);

    ubyte[16] digest;
    auto hash = new MD5Digest();
    foreach (s; File(args[1]).byLine().filter!(a => a != ""))
    {
        digest = hash.digest(s);
        uint idx = (
                    (digest[0] << 24) |
                    (digest[1] << 16) |
                    (digest[2] << 8) | digest[3]
                   ) >> (32 - size);
        idx = (idx % ((2 ^^ size) - 1));
        index[idx] = 1;
    }

    size_t numElems;
    size_t setElems;

    foreach (e; index)
    {
        if (e) { setElems++; }
        numElems++;
    }

    writefln("Total: %d, Set: %d, Ratio: %f", numElems, setElems,
             ((cast(double)setElems / cast(double)numElems) * 100));
}
