import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

struct SLList(T)
{
    SLNode!(T) head;

    // Add a new value to the end of the list.
    void add(T val)
    {
        SLNode!(T) newNode = new SLNode!(T)(val);
        if (head is null)
        {
            head = newNode;
        }
        else
        {
            SLNode!(T) currNode = head;
            while(currNode.next !is null)
            {
                currNode = currNode.next;
            }
            currNode.next = newNode;
        }
    }

    // Find a node within the list.
    SLNode!(T) find(T val)
    {
        SLNode!(T) currNode = head;
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

    // Delete a value from the list.
    void remove(SLNode!(T) node)
    {
        if (node == head && head.next is null)
        {
            head = null;
        }
        else if (node == head)
        {
            head = head.next;
        }
        else
        {
            SLNode!(T) parent = head;
            while (parent.next != node)
            {
                parent = parent.next;
            }
            parent.next = node.next;
        }
    }

    // Return all of the value in the list as an array.
    @property T[] values()
    {
        T[] values;
        if (head is null)
        {
            return values;
        }

        SLNode!(T) currNode = head;
        while (currNode !is null)
        {
            values ~= currNode.value;
            currNode = currNode.next;
        }
        return values;
    }
}

class SLNode(T)
{
    T value;
    SLNode!(T) next;

    this(T val)
    {
        value = val;
    }
}

unittest
{
    SLList!(string) list;
    assert(list.find("fred") is null);
    list.add("fred");
    assert(["fred"] == list.values());
    assert(list.find("fred") !is null);
    assert(list.find("fred").value == "fred");
    list.add("wilma");
    assert(["fred", "wilma"] == list.values());
    assert(list.find("wilma") !is null);
    assert(list.find("wilma").value == "wilma");
    list.remove(list.find("wilma"));
    assert(["fred"] == list.values());
    assert(list.find("wilma") is null);
    list.remove(list.find("fred"));
    assert([] == list.values());
    assert(list.find("fred") is null);

    list.add("a");
    list.add("b");
    list.add("c");
    list.remove(list.find("a"));
    assert(["b", "c"] == list.values);
    list.remove(list.find("c"));
    assert(["b"] == list.values);
}

struct DLList(T)
{
    DLNode!(T) head;
    DLNode!(T) last;

    // Add a new value to the end of the list.
    void add(T val)
    {
        DLNode!(T) newNode = new DLNode!(T)(val);
        if (head is null)
        {
            head = newNode;
        }
        else
        {
            last.next = newNode;
            newNode.prev = last;
        }
        last = newNode;
    }

    // Find a node within the list.
    DLNode!(T) find(T val)
    {
        DLNode!(T) currNode = head;
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

    // Delete a value from the list.
    void remove(DLNode!(T) node)
    {
        if (node == head && head.next is null)
        {
            head = null;
            last = null;
        }
        else if (node == head)
        {
            head = head.next;
            head.prev = null;
        }
        else
        {
            DLNode!(T) parent = node.prev;
            parent.next = node.next;

            if (parent.next is null)
            {
                last = parent;
            }
            else
            {
                parent.next.prev = parent;
            }
        }
    }

    // Return all of the value in the list as an array.
    @property T[] values()
    {
        T[] values;
        if (head is null)
        {
            return values;
        }

        DLNode!(T) currNode = head;
        while (currNode !is null)
        {
            values ~= currNode.value;
            currNode = currNode.next;
        }
        return values;
    }
}

class DLNode(T)
{
    T value;
    DLNode!(T) next, prev;

    this(T val)
    {
        value = val;
    }
}

unittest
{
    DLList!(string) list;
    assert(list.find("fred") is null);
    list.add("fred");
    assert(["fred"] == list.values());
    assert(list.find("fred") !is null);
    assert(list.find("fred").value == "fred");
    list.add("wilma");
    assert(["fred", "wilma"] == list.values());
    assert(list.find("wilma") !is null);
    assert(list.find("wilma").value == "wilma");
    list.remove(list.find("wilma"));
    assert(["fred"] == list.values());
    assert(list.find("wilma") is null);
    list.remove(list.find("fred"));
    assert([] == list.values());
    assert(list.find("fred") is null);

    list.add("a");
    list.add("b");
    list.add("c");
    list.remove(list.find("a"));
    assert(["b", "c"] == list.values);
    list.remove(list.find("c"));
    assert(["b"] == list.values);
}

struct ArrayList(T)
{
    ArrayNode!(T)[] vals;
    size_t index;

    // Add a new value to the end of the list.
    void add(T val)
    {
        if (index == index.max)
        {
            throw new Exception("Cannot add any more vals!");
        }
        if (index == 0)
        {
            vals.length = 10;
        }
        else if (index == vals.length)
        {
            if ((index.max / 2) > vals.length)
            {
                vals.length = vals.length * 2;
            }
            else
            {
                vals.length = index.max;
            }
        }
        vals[index] = new ArrayNode!(T)();
        vals[index].value = val;
        vals[index].index = index;
        index++;
    }

    // Find a node within the list.
    ArrayNode!(T) find(T val)
    {
        for(int i = 0; i < index; i++)
        {
            if (vals[i].value == val)
            {
                return vals[i];
            }
        }
        return null;
    }

    // Delete a value from the list.
    void remove(ArrayNode!(T) node)
    {
        for (int i = node.index; i < index; i++)
        {
            vals[i] = (i+1) < vals.length ? vals[i+1] : null;
        }
        index--;
    }

    @property T[] values()
    {
        return vals[0..index].map!(a => a.value)().array;
    }
}

class ArrayNode(T)
{
    T value;
    size_t index;
}

unittest
{
    ArrayList!(string) list;
    assert(list.find("fred") is null);
    list.add("fred");
    assert(["fred"] == list.values());
    assert(list.find("fred") !is null);
    assert(list.find("fred").value == "fred");
    list.add("wilma");
    assert(["fred", "wilma"] == list.values());
    assert(list.find("wilma") !is null);
    assert(list.find("wilma").value == "wilma");
    list.remove(list.find("wilma"));
    assert(["fred"] == list.values());
    assert(list.find("wilma") is null);
    list.remove(list.find("fred"));
    assert([] == list.values());
    assert(list.find("fred") is null);

    list.add("a");
    list.add("b");
    list.add("c");
    list.remove(list.find("a"));
    assert(["b", "c"] == list.values);
    list.remove(list.find("c"));
    assert(["b"] == list.values);
}

SLList!int testList1;
DLList!int testList2;
ArrayList!int testList3;

void main()
{
    writeln("Benchmarking adds.");
    auto r = benchmark!(add1, add2, add3)(100);
    for (int i = 0; i < 3; i++)
    {
        writefln("Add%d: %d", i+1, r[i].to!("usecs", int));
    }

    writeln("Benchmarking finds.");
    for (int i = 0; i < 1000; i++)
    {
        testList1.add(i);
        testList2.add(i);
        testList3.add(i);
    }
    r = benchmark!(find1, find2, find3)(100);
    for (int i = 0; i < 3; i++)
    {
        writefln("Find%d: %d", i+1, r[i].to!("usecs", int));
    }
}

void add1()
{
    SLList!int list;
    for (int i = 0; i < 1000; i++)
    {
        list.add(i);
    }
}

void add2()
{
    DLList!int list;
    for (int i = 0; i < 1000; i++)
    {
        list.add(i);
    }
}

void add3()
{
    ArrayList!int list;
    for (int i = 0; i < 1000; i++)
    {
        list.add(i);
    }
}

void find1()
{
    for (int i = 0; i < 1000; i++)
    {
        auto result = testList1.find(i);
    }
}

void find2()
{
    for (int i = 0; i < 1000; i++)
    {
        auto result = testList2.find(i);
    }
}

void find3()
{
    for (int i = 0; i < 1000; i++)
    {
        auto result = testList3.find(i);
    }
}
