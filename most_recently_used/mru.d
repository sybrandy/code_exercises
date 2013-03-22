import core.thread;
import core.time;
import std.datetime;
import std.range;
import std.stdio;

void main()
{
}

struct MRUList(T)
{
    Node!(T) head;
    Node!(T) last;
    int expiration = 10;

    // Add a new value to the head of the list.
    void put(T val)
    {
        Node!(T) currNode = find(val);

        if (currNode is null)
        {
            Node!(T) newNode = new Node!(T)(val);
            if (last is null)
            {
                last = newNode;
            }
            else
            {
                if (head.next !is null)
                {
                    head.prev = newNode;
                    newNode.next = head;
                }
                else
                {
                    newNode.next = last;
                    last.prev = newNode;
                }
            }
            head = newNode;
        }
        else if (currNode.prev !is null)
        {
            if (currNode.next !is null)
            {
                currNode.next.prev = currNode.prev;
            }
            if (currNode.prev !is null)
            {
                currNode.prev.next = currNode.next;
            }
            head.prev = currNode;
            currNode.next = head;
            currNode.prev = null;
            head = currNode;
        }
    }

    @property T front()
    {
        return head.value;
    }

    void popFront()
    {
        if (head.next !is null)
        {
            head = head.next;
            head.prev = null;
        }
        else
        {
            head = null;
            last = null;
        }
    }

    @property bool empty()
    {
        return head is null;
    }

    // Find a node within the list.
    private Node!(T) find(T val)
    {
        Node!(T) currNode = head;
        while (currNode !is null)
        {
            if (currNode.value == val)
            {
                return currNode;
            }
            currNode = currNode.next;
        }
        return null;
    }

    // Return all of the value in the list as an array.
    @property T[] values()
    {
        T[] values;
        if (head is null)
        {
            return values;
        }

        Node!(T) currNode = head;
        while (currNode !is null)
        {
            values ~= currNode.value;
            currNode = currNode.next;
        }
        return values;
    }

    @property T[] topEntries()
    {
        T[] vals;
        Node!(T) temp = head;
        foreach (i; 1..11)
        {
            if (temp is null) break;
            vals ~= temp.value;
            temp = temp.next;
        }
        return vals;
    }

    void clear()
    {
        SysTime currTime = Clock.currTime() - dur!"seconds"(expiration);
        while (last !is null && last.ts < currTime)
        {
            if (last == head)
            {
                last = null;
                head = null;
                break;
            }
            last = last.prev;
            last.next = null;
        }
    }
}

unittest
{
    static assert(isOutputRange!(MRUList!string, string));
    static assert(isInputRange!(MRUList!string));

    MRUList!(int) test;
    assert([] == test.values);
    test.put(1);
    assert([1] == test.values);
    test.put(1);
    assert([1] == test.values);
    test.put(2);
    assert([2,1] == test.values);
    test.put(1);
    assert([1,2] == test.values);
    test.put(1);
    assert([1,2] == test.values);
    test.put(3);
    assert([3,1,2] == test.values);
    test.put(1);
    assert([1,3,2] == test.values);

    assert(!test.empty);
    assert(1 == test.front);
    test.popFront();
    assert(!test.empty);
    assert(3 == test.front);
    test.popFront();
    assert(!test.empty);
    assert(2 == test.front);
    test.popFront();
    assert(test.empty);

    test.put(1);
    test.put(2);
    test.put(3);
    assert([3,2,1] == test.topEntries);
    test.put(4);
    test.put(5);
    test.put(6);
    test.put(7);
    test.put(8);
    test.put(9);
    test.put(10);
    test.put(11);
    test.put(12);
    test.put(13);
    assert([13,12,11,10,9,8,7,6,5,4] == test.topEntries);

    writeln("Starting the clear test.  This will take about 20 seconds.");
    MRUList!(int) clearTest;
    for (int i = 0; i < 20; i++)
    {
        clearTest.put(i);
        if (i < 19)
        {
            Thread.sleep(dur!("seconds")(1));
        }
    }
    clearTest.clear;
    assert([19, 18, 17, 16, 15, 14, 13, 12, 11, 10] == clearTest.values);
}

class Node(T)
{
    T value;
    SysTime ts;
    Node!(T) next, prev;

    this(T val)
    {
        value = val;
        ts = Clock.currTime();
    }
}
