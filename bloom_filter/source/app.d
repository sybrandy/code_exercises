import std.algorithm;
import std.bitmanip;
import std.digest.md;
import std.exception;
import std.file;
import std.random;
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
    size += 3; // Better ratio of set vs. non-set bits.
    writeln("Size: ", size);

    BitArray index;
    index.length = (2 ^^ size) - 1;
    writeln("Length: ", index.length);
    writeln("Words: ", index.dim);

    ubyte[16] digest;
    foreach (s; File(args[1]).byLine().filter!(a => a != ""))
    {
        digest = md5Of(s);
        uint idx = (
                    (digest[0] << 24) |
                    (digest[1] << 16) |
                    (digest[2] << 8) | digest[3]
                   ) >> (32 - size);
        idx = (idx % ((2 ^^ size) - 1));
        index[idx] = 1;
    }

    size_t setElems;

    foreach (e; index)
    {
        if (e) { setElems++; }
    }

    writefln("Total: %d, Set: %d, Ratio: %f", index.length, setElems,
             ((cast(double)setElems / cast(double)index.length) * 100));

    // Generate some random words and see how many false positives we get.
    auto gen = Random(unpredictableSeed);
    int numHits;
    int falsePositives;
    for (int i = 0; i < 100; i++)
    {
        char[5] buff;
        for (int j = 0; j < 5; j++)
        {
            buff[j] = cast(char)uniform(97, 123, gen);
        }
        digest = md5Of(buff);
        uint idx = (
                    (digest[0] << 24) |
                    (digest[1] << 16) |
                    (digest[2] << 8) | digest[3]
                   ) >> (32 - size);
        idx = (idx % ((2 ^^ size) - 1));
        if (index[idx] == 1)
        {
            writeln("Found word: ", buff);
            numHits++;
            auto found = find(File(args[1]).byLine(), buff);
            if (found.empty)
            {
                falsePositives++;
            }
        }
    }
    writeln("Num hits: ", numHits);
    writeln("Num false positives: ", falsePositives);
}
