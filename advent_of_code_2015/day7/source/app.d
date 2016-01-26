import std.stdio, std.array, std.string, std.algorithm, std.conv;

string buff = import("input");
string sample = q"EOS
123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i
EOS";

struct Wire
{
    string src1, src2, op;
    ushort val, mod;
    bool isSet;
}

void main()
{
    Wire[string] wires;
    /* foreach (i; sample.strip.split("\n")) */
    foreach (i; buff.strip.split("\n"))
    {
        parseWire(wires, i);
    }
    writeln("Original value for wire A: ", getValue(wires, "a"));

    wires["b"].val = getValue(wires, "a");
    foreach (i; wires.keys)
    {
        wires[i].isSet = false;
    }
    wires["b"].isSet = true;
    writeln("New value for wire A: ", getValue(wires, "a"));
    /* foreach (i; wires.keys) */
    /* { */
    /*     writefln("%s - %d", i, getValue(wires, i)); */
    /* } */
}

ushort getValue(ref Wire[string]wires, string key)
{
    Wire currWire = wires[key];
    if (currWire.isSet)
        return currWire.val;

    final switch (currWire.op)
    {
        case "SET":
            currWire.val = isNumeric(currWire.src1)
                         ? to!ushort(currWire.src1)
                         : getValue(wires, currWire.src1);
            break;
        case "AND":
            ushort val1 = isNumeric(currWire.src1)
                        ? to!ushort(currWire.src1)
                        : getValue(wires, currWire.src1);
            ushort val2 = isNumeric(currWire.src2)
                         ? to!ushort(currWire.src2)
                         : getValue(wires, currWire.src2);
            currWire.val = val1 & val2;
            break;
        case "OR":
            ushort val1 = isNumeric(currWire.src1)
                        ? to!ushort(currWire.src1)
                        : getValue(wires, currWire.src1);
            ushort val2 = isNumeric(currWire.src2)
                         ? to!ushort(currWire.src2)
                         : getValue(wires, currWire.src2);
            currWire.val = val1 | val2;
            break;
        case "LSHIFT":
            ushort val1 = isNumeric(currWire.src1)
                        ? to!ushort(currWire.src1)
                        : getValue(wires, currWire.src1);
            currWire.val = to!ushort(val1 << currWire.mod);
            break;
        case "RSHIFT":
            ushort val1 = isNumeric(currWire.src1)
                        ? to!ushort(currWire.src1)
                        : getValue(wires, currWire.src1);
            currWire.val = val1 >> currWire.mod;
            break;
        case "NOT":
            ushort val1 = isNumeric(currWire.src1)
                        ? to!ushort(currWire.src1)
                        : getValue(wires, currWire.src1);
            currWire.val = val1 ^ ushort.max;
            break;
    }

    currWire.isSet = true;
    wires[key] = currWire;
    return currWire.val;
}

void parseWire(ref Wire[string] wires, string input)
{
    Wire currWire;
    auto parts = input.split;
    if (parts[1] == "LSHIFT" || parts[1] == "RSHIFT")
    {
        currWire.mod = to!ushort(parts[2]);
        currWire.src1 = parts[0];
        currWire.op = parts[1];
        wires[parts[4]] = currWire;
    }
    else if (parts[1] == "AND" || parts[1] == "OR")
    {
        currWire.src1 = parts[0];
        currWire.src2 = parts[2];
        currWire.op = parts[1];
        wires[parts[4]] = currWire;
    }
    else if (parts[0] == "NOT")
    {
        currWire.src1 = parts[1];
        currWire.op = parts[0];
        wires[parts[3]] = currWire;
    }
    else if (parts.length == 3)
    {
        currWire.src1 = parts[0];
        currWire.op = "SET";
        wires[parts[2]] = currWire;
    }
}
