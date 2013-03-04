import std.array;
import std.conv;
import std.stdio;
import std.string;

struct Pricing
{
    int unit;
    int specialAmount;
    int specialPrice;

    this(string u, string a = "0", string p = "0")
    {
        this.unit = parse!int(u);
        this.specialAmount = parse!int(a);
        this.specialPrice = parse!int(p);
    }
}

struct CheckOut
{
    Pricing[char] rules;
    int[char] order;
    int total;

    this(string fname)
    {
        bool endHeader = false;
        foreach (line; File(fname).byLine)
        {
            if (endHeader)
            {
                string[] parts = split(line.idup.strip);
                if (parts.length == 2)
                {
                    char[] temp = parts[0].dup;
                    rules[temp[0]] = Pricing(parts[1]);
                }
                else
                {
                    char[] temp = parts[0].dup;
                    rules[temp[0]] = Pricing(parts[1], parts[2], parts[4]);
                }
            }
            else if (line[0] == '-')
            {
                endHeader = true;
            }
        }
    }

    void scan(char item)
    {
        this.order[item]++;
        Pricing price = this.rules[item];
        this.total += price.unit;
        if (price.specialAmount > 0 && (this.order[item] % price.specialAmount) == 0)
        {
            this.total -= price.specialAmount * price.unit;
            this.total += price.specialPrice;
        }
    }
}

int price(string items)
{
    auto co = CheckOut("RULES.txt");
    foreach (c; items.dup)
    {
        co.scan(c);
    }
    return co.total;
}

void main()
{
    auto co = CheckOut("RULES.txt");
    assert(0 == co.total);
    co.scan('A');
    assert(50 == co.total);
    co.scan('B');
    assert(80 == co.total);
    co.scan('A');
    assert(130 == co.total);
    co.scan('A');
    assert(160 == co.total);
    co.scan('B');
    assert(175 == co.total);

    assert(  0 == price(""));
    assert( 50 == price("A"));
    assert( 80 == price("AB"));
    assert(115 == price("CDBA"));

    assert(100 == price("AA"));
    assert(130 == price("AAA"));
    assert(180 == price("AAAA"));
    assert(230 == price("AAAAA"));
    assert(260 == price("AAAAAA"));

    assert(160 == price("AAAB"));
    assert(175 == price("AAABB"));
    assert(190 == price("AAABBD"));
    assert(190 == price("DABABA"));
}
