import std.algorithm;
import std.array;
import std.ascii;
import std.conv;
import std.stdio;
import std.string;

void main()
{
}

struct Caesar
{
    static dchar doShift(dchar c, int shift)
    {
        return isAlpha(c)
             ?  c = ((c - 97 + shift) % 26) + 97
             : c;
    }

    static string enc(string pt, int shift)
    {
        return to!(string)(pt.toLower.map!(a => doShift(a, shift)).array());
    }

    static string dec(string ct, int shift)
    {
        int newShift = 26 - shift;
        return to!(string)(ct.toLower.map!(a => doShift(a, newShift)).array());
    }
}

unittest
{
    assert(Caesar.doShift('x', 1) == 'y');
    assert(Caesar.doShift('y', 1) == 'z');
    assert(Caesar.doShift('z', 1) == 'a');
    assert(Caesar.dec(Caesar.enc("abcdefg", 5), 5) == "abcdefg");
    assert(Caesar.dec(Caesar.enc("ABCDEFG", 5), 5) == "abcdefg");
    assert(Caesar.dec(Caesar.enc("How are things going?", 5), 5) == "how are things going?");
}

struct Viginere
{
    static int getShift(string key, int keyIdx)
    {
        return (key.dup)[keyIdx] - 96;
    }

    static string enc(string pt, string key)
    {
        auto ct = appender!(char[]);
        int keyIdx = 0;
        foreach (c; pt.toLower.dup)
        {
            if (isAlpha(c))
            {
                int shift = getShift(key, keyIdx);
                ct.put(Caesar.doShift(c, shift));
                keyIdx = (keyIdx + 1) % key.length;
            }
            else
            {
                ct.put(c);
            }
        }
        return ct.data.idup;
    }

    static string dec(string ct, string key)
    {
        auto pt = appender!(char[]);
        int keyIdx = 0;
        foreach (c; ct.toLower.dup)
        {
            if (isAlpha(c))
            {
                int shift = 26 - getShift(key, keyIdx);
                pt.put(Caesar.doShift(c, shift));
                keyIdx = (keyIdx + 1) % key.length;
            }
            else
            {
                pt.put(c);
            }
        }
        return pt.data.idup;
    }
}

unittest
{
    assert(Viginere.dec(Viginere.enc("aaaaaa", "a"), "a") == "aaaaaa");
    assert(Viginere.dec(Viginere.enc("aaaaaa", "z"), "z") == "aaaaaa");
    assert(Viginere.dec(Viginere.enc("abcdefg", "key"), "key") == "abcdefg");
    assert(Viginere.dec(Viginere.enc("ABCDEFG", "key"), "key") == "abcdefg");
    assert(Viginere.dec(Viginere.enc("How are things going?", "key"), "key") == "how are things going?");
}

struct Autokey
{
    static string enc(string pt, string key)
    {
        string newKey = to!(string)(filter!(a => isAlpha(a))((key ~ pt).toLower).array());
        return Viginere.enc(pt, newKey);
    }

    static string dec(string ct, string key)
    {
        auto pt = appender!(char[]);
        dchar[] newKey = to!(dchar[])(key);
        int keyIdx = 0;
        foreach (c; ct.toLower.dup)
        {
            if (isAlpha(c))
            {
                int shift = 26 - (newKey[keyIdx++] - 96);
                dchar pc = Caesar.doShift(c, shift);
                pt.put(pc);
                newKey ~= pc;
            }
            else
            {
                pt.put(c);
            }
        }
        return pt.data.idup;
    }
}

unittest
{
    assert(Autokey.dec(Autokey.enc("abcdefg", "key"), "key") == "abcdefg");
    assert(Autokey.dec(Autokey.enc("ABCDEFG", "key"), "key") == "abcdefg");
    assert(Autokey.dec(Autokey.enc("How are things going?", "key"), "key") == "how are things going?");
}

struct Sub
{
    static char[char] inverseKey(char[char] key)
    {
        char[char] newKey;
        foreach (k, v; key)
        {
            newKey[v] = k;
        }
        return newKey;
    }

    static string enc(string pt, char[char] key)
    {
        auto ct = appender!(char[]);
        foreach (c; pt.toLower.dup)
        {
            if (isAlpha(c)) ct.put(key[c]);
        }
        return ct.data.idup;
    }

    static string dec(string ct, char[char] key)
    {
        char[char] newKey = inverseKey(key);
        auto pt = appender!(char[]);
        foreach (c; ct.toLower.dup)
        {
            if (isAlpha(c)) pt.put(newKey[c]);
        }
        return pt.data.idup;
    }
}

unittest
{
    char[char] key = ['a': 'z', 'b': 'y', 'c': 'x', 'd': 'w', 'e': 'v',
                      'f': 'u', 'g': 't'];
    assert(Sub.dec(Sub.enc("abcdefg", key), key) == "abcdefg");
    assert(Sub.dec(Sub.enc("ABCDEFG", key), key) == "abcdefg");
}

struct OTP
{
    static ubyte[] enc(ubyte[] msg, ubyte[] key)
    {
        ubyte[] output;
        output.length = msg.length;
        if (msg.length != key.length)
        {
            throw new Exception("Message and key must be the same length!");
        }

        for (int i = 0; i < msg.length; i++)
        {
            output[i] = msg[i] ^ key[i];
        }
        return output;
    }
}

unittest
{
    ubyte[7] data = [97, 98, 99, 100, 101, 102, 103];
    ubyte[7] key = [1, 1, 1, 1, 1, 1, 1];
    assert(OTP.enc(OTP.enc(data, key), key) == data);
}
