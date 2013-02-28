module diff;

import std.math : abs;

struct Record(T)
{
    T id;
    int min;
    int max;
    int diff;

    this(T id, int min, int max)
    {
        this.id = id;
        this.min = min;
        this.max = max;
    }
}

void findMinDiff(Source, Rec)(Source src, ref Rec rec)
{
    rec.diff = 100;

    foreach (s; src)
    {
        int diff = abs(s.max - s.min);
        if (diff < rec.diff)
        {
            rec.diff = diff;
            rec.id = s.id;
        }
    }
}
