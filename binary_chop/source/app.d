import std.concurrency;
import std.datetime;
import std.stdio;
import core.thread;

/*
    Binary Chop (E.g. binary search) code kata.

    Create 5 versions of the same algorithm.  All should pass the same tests.
 */

// First version, use a simple loop.
pure nothrow
long chop1(long val, long[] values)
{
    if (values.length == 1 && values[0] == val)
    {
        return 0;
    }
    else if (values.length > 1)
    {
        long index = values.length / 2;
        long maxIndex = values.length - 1;
        while(index >= 0)
        {
            if (values[index] == val)
            {
                return index;
            }
            else if (index == maxIndex)
            {
                break;
            }
            else if (values[index] < val)
            {
                long temp = ((maxIndex - index) / 2);
                index += (temp > 0) ? temp : 1;
            }
            else
            {
                maxIndex = index;
                long temp = index / 2;
                index -= (temp > 0) ? temp : 1;
            }
        }
    }

    return -1;
}

// Second version: create a version that accepts the index to check as a
// parameter, then recursively call the method.
pure nothrow
long chop2(long val, long[] values)
{
    if (values.length < 1)
    {
        return -1;
    }

    if (values.length == 1 && values[0] == val)
    {
        return 0;
    }

    return doChop2(val, values, 0, values.length - 1);
}

pure nothrow
long doChop2(long val, long[] values, long start, long end)
{
    if (start > end)
    {
        return -1;
    }

    long diff = end - start;
    long index = (diff != 1)
              ? start + (diff / 2)
              : start;
    if (values[index] == val)
    {
        return index;
    }
    else if (values[index] > val)
    {
        return doChop2(val, values, start, index - 1);
    }
    else
    {
        return doChop2(val, values, index + 1, end);
    }
}

// Third version: use array slices and recursion.
pure nothrow
long chop3(long val, long[] values)
{
    if (values.length == 1 && values[0] == val)
    {
        return 0;
    }
    else if (values.length <= 1)
    {
        return -1;
    }

    long index = values.length / 2;
    if (values[index] == val)
    {
        return index;
    }
    else if (values[index] > val)
    {
        return chop3(val, values[0..index]);
    }
    else
    {
        long retVal = chop3(val, values[index..$]);
        return (retVal >= 0) ? retVal + index : retVal;
    }
}

// Fourth version: In this version, we use fibers to do the checks.
long chop4(long val, long[] values)
{
    ChopFiber cf = new ChopFiber(val, values);
    cf.call();
    return cf.index;
}

class ChopFiber: Fiber
{
    long index = -1;
    long val;
    long[] values;

    this(long _val, long[] _values)
    {
        this.val = _val;
        this.values = _values.dup;
        super(&run);
    }

    private void run()
    {
        if (this.values.length == 1 && this.values[0] == this.val)
        {
            this.index = 0;
        }
        else if (this.values.length <= 1)
        {
            this.index = -1;
        }
        else
        {
            long index = this.values.length / 2;
            if (this.values[index] == this.val)
            {
                this.index = index;
            }
            else if (this.values[index] > this.val)
            {
                ChopFiber cf = new ChopFiber(this.val, this.values[0..index]);
                cf.call();
                this.index = cf.index;
            }
            else
            {
                ChopFiber cf = new ChopFiber(this.val, this.values[index..$]);
                cf.call();
                this.index = (cf.index >= 0) ? cf.index + index : cf.index;
            }
        }
    }
}

// Fifth version: In this version, we use threads to do the checks
// concurrently.
long chop5(long val, long[] values)
{
    ChopThread ct = new ChopThread(val, values);
    ct.start();
    ct.join();
    return ct.index;
}

class ChopThread: Thread
{
    long index = -1;
    long val;
    long[] values;

    this(long _val, long[] _values)
    {
        this.val = _val;
        this.values = _values.dup;
        super(&run);
    }

    private void run()
    {
        if (this.values.length == 1 && this.values[0] == this.val)
        {
            this.index = 0;
        }
        else if (this.values.length <= 1)
        {
            this.index = -1;
        }
        else
        {
            long index = this.values.length / 2;
            if (this.values[index] == this.val)
            {
                this.index = index;
            }
            else if (this.values[index] > this.val)
            {
                ChopThread ct1 = new ChopThread(this.val, this.values[0..index]);
                ct1.start();
                ct1.join();
                this.index = ct1.index;
            }
            else
            {
                ChopThread ct2 = new ChopThread(this.val, this.values[index..$]);
                ct2.start();
                ct2.join();
                this.index = (ct2.index >= 0) ? ct2.index + index : ct2.index;
            }
        }
    }
}

// Sixth version: use message passing!
void spawnChop(Tid tid)
{
    receive
    (
        (long val, immutable(long)[] values)
        {
            long index = values.length / 2;
            long maxIndex = values.length - 1;
            long retVal = -1;
            while(index >= 0)
            {
                if (values[index] == val)
                {
                    retVal = index;
                    break;
                }
                else if (index == maxIndex)
                {
                    break;
                }
                else if (values[index] < val)
                {
                    long temp = ((maxIndex - index) / 2);
                    index += (temp > 0) ? temp : 1;
                }
                else
                {
                    maxIndex = index;
                    long temp = index / 2;
                    index -= (temp > 0) ? temp : 1;
                }
            }
            send(tid, retVal);
        }
    );
}

long chop6(long val, long[] values)
{
    if (values.length == 0)
    {
        return -1;
    }
    else if (values.length == 1 && values[0] == val)
    {
        return 0;
    }
    else
    {
        auto tid = spawn(&spawnChop, thisTid);
        send(tid, val, values.idup);
        return receiveOnly!(long);
    }
}

void testChop(long function(long, long[]) chop)
{
    assert(-1 == chop(3, []));
    assert(-1 == chop(3, [1]));
    assert(0 ==  chop(1, [1]));
    assert(0 ==  chop(1, [1, 3, 5]));
    assert(1 ==  chop(3, [1, 3, 5]));
    assert(2 ==  chop(5, [1, 3, 5]));
    assert(-1 == chop(0, [1, 3, 5]));
    assert(-1 == chop(2, [1, 3, 5]));
    assert(-1 == chop(4, [1, 3, 5]));
    assert(-1 == chop(6, [1, 3, 5]));
    assert(0 ==  chop(1, [1, 3, 5, 7]));
    assert(1 == chop(3, [1, 3, 5, 7]));
    assert(2 == chop(5, [1, 3, 5, 7]));
    assert(3 == chop(7, [1, 3, 5, 7]));
    assert(-1 == chop(0, [1, 3, 5, 7]));
    assert(-1 == chop(2, [1, 3, 5, 7]));
    assert(-1 == chop(4, [1, 3, 5, 7]));
    assert(-1 == chop(6, [1, 3, 5, 7]));
    assert(-1 == chop(8, [1, 3, 5, 7]));
}

immutable long dataSize = 1000000;
long[dataSize] data;

void main()
{
    testChop(&chop1);
    testChop(&chop2);
    testChop(&chop3);
    testChop(&chop4);
    testChop(&chop5);
    testChop(&chop6);

    for (long i = 0; i < dataSize; i++)
    {
        data[i] = i;
    }

    auto r = benchmark!(bench1, bench2, bench3, bench4, bench5, bench6)(100);
    for (long i = 0; i < 6; i++)
    {
        writefln("Bench%d: %d", i+1, r[i].to!("usecs", long));
    }
}

void bench1()
{
    chop1(1, data);
}

void bench2()
{
    chop2(1, data);
}

void bench3()
{
    chop3(1, data);
}

void bench4()
{
    chop4(1, data);
}

void bench5()
{
    chop5(1, data);
}

void bench6()
{
    chop6(1, data);
}
