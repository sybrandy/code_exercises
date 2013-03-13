import std.algorithm;
import std.array;
import std.range;
import std.stdio;

enum Status : string { VALID = "", ILLEGAL = "ILL", ERROR = "ERR" };

void main()
{
}

pure nothrow int[string] getMapping()
{
    int[string] stringToNum = [" _ " ~
                               "| |" ~
                               "|_|":0,
                               "   " ~
                               "  |" ~
                               "  |":1,
                               " _ " ~
                               " _|" ~
                               "|_ ":2,
                               " _ " ~
                               " _|" ~
                               " _|":3,
                               "   " ~
                               "|_|" ~
                               "  |":4,
                               " _ " ~
                               "|_ " ~
                               " _|":5,
                               " _ " ~
                               "|_ " ~
                               "|_|":6,
                               " _ " ~
                               "  |" ~
                               "  |":7,
                               " _ " ~
                               "|_|" ~
                               "|_|":8,
                               " _ " ~
                               "|_|" ~
                               " _|":9];
    return stringToNum;
}

pure int[9] scanNumbers(in string[3] scanLine)
{
    return scanNumbers(toDigits(scanLine));
}

pure int[9] scanNumbers(in string[9] scanLine)
{
    int[9] numData = [-1, -1, -1, -1, -1, -1, -1, -1, -1];
    auto stringToNum = getMapping();

    for (int i = 0; i < 9; i++)
    {
        numData[i] = (scanLine[i].idup in stringToNum)
                   ?  stringToNum[scanLine[i].idup]
                   : -1;
    }

    return numData;
}

pure Status validScan(in int[9] nums)
{
    /*writeln("Checking nums: ", nums);*/
    if (count!(a => a == -1)(nums.dup))
    {
        return Status.ILLEGAL;
    }

    int sum;
    for (int i = 1, j = 8; j >= 0; j--, i++)
    {
        /*writefln("Num %d, multiplier: %d", nums[j], i);*/
        sum += nums[j] * i;
    }

    /*writefln("Sum %d and modulous %d", sum, sum % 11);*/
    if (sum % 11)
    {
        return Status.ERROR;
    }

    return Status.VALID;
}

pure nothrow string[9] toDigits(in string[3] scanLine)
{
    string[9] digits;
    for (int i = 0; i < 9; i++)
    {
        int start = i * 3;
        int end = start + 3;
        digits[i] = scanLine[0][start..end] ~ scanLine[1][start..end] ~ scanLine[2][start..end];
    }
    return digits;
}

string getNumber(in string[3] scanLine)
{
    int[9] nums = scanNumbers(scanLine);
    Status stat = validScan(nums);
    /*writeln("Numbers: ", nums);*/
    /*writeln("Status: ", stat);*/
    string result;

    if (stat == Status.VALID)
    {
        /*writeln("Valid value found!");*/
        return nums.dup.map!(a => (a == -1) ? '?' : cast(char)(a + 48))().array.idup;
    }

    string[9][] fixed;
    /*writeln("Looping over fixNumber.");*/
    foreach (s; fixNumber(toDigits(scanLine)))
    {
        /*writeln("Valid: ", validScan(scanNumbers(s)));*/
        if (validScan(scanNumbers(s)) == Status.VALID)
        {
            fixed ~= s;
        }
    }

    /*writeln("Number of fixed values: ", fixed.length);*/
    /*writeln("Fixed: ", fixed);*/
    if (fixed.length == 0)
    {
        result = nums.dup.map!(a => (a == -1) ? '?' : cast(char)(a + 48))().array.idup;
        return result ~ " " ~ cast(string)stat;
    }
    else if (fixed.length == 1)
    {
        return scanNumbers(fixed[0]).dup.map!(a => (a == -1) ? '?' : cast(char)(a + 48))().array.idup;
    }

    result = nums.dup.map!(a => (a == -1) ? '?' : cast(char)(a + 48))().array.idup;
    result ~= " AMB ['";
    string[] tempVals;
    foreach (f; fixed)
    {
        tempVals ~= f.scanNumbers.dup.map!(a => (a == -1) ? '?' : cast(char)(a + 48))().array.idup;
    }
    result ~= tempVals.sort.uniq.array.join("', '");
    result ~= "']";
    return result;
}

string[9][] fixNumber(in string[9] digits, in int index = 0)
{
    string[9][] nums;
    /*writeln("Digits: ", digits);*/
    /*writeln("Current index: ", index);*/

    foreach (k; getMapping().keys)
    {
        int diff = k.wordDiff(digits[index]);
        string[9] temp = digits.dup;
        if (diff <= 1)
        {
            temp[index] = k;
            nums ~= temp;
        }
    }
    if (index != 8)
    {
        nums = chain(nums, fixNumber(digits, index+1)).array;
    }

    if (index == 0)
    {
        /*writeln("Returning the sorted and unique results.");*/
        string[9][string] tempMap;
        foreach (n; nums)
        {
            tempMap[join(n.dup)] = n;
        }
        nums.length = 0;
        foreach (k; tempMap.keys.sort())
        {
            nums ~= tempMap[k];
        }
    }
    /*writeln("Returning the results.");*/
    return nums;
}

pure int wordDiff(string word1, string word2)
{
    char[] w1 = word1.dup;
    char[] w2 = word2.dup;
    int numDiffs;
    for (int i = 0; i < w1.length; i++)
    {
        numDiffs = (w1[i] == w2[i]) ? numDiffs : numDiffs + 1;
    }
    return numDiffs;
}

unittest
{
    int[9] nums = [3, 4, 5, 8, 8, 2, 8, 6, 5];
    assert(nums.validScan() == Status.VALID);
    string[3] currData;
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = "| || || || || || || || || |";
    currData[2] = "|_||_||_||_||_||_||_||_||_|";
    nums = scanNumbers(currData);
    assert(nums == [0,0,0,0,0,0,0,0,0]);
    currData[0] = "                           ";
    currData[1] = "  |  |  |  |  |  |  |  |  |";
    currData[2] = "  |  |  |  |  |  |  |  |  |";
    nums = scanNumbers(currData);
    assert(nums == [1,1,1,1,1,1,1,1,1]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "711111111");
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = " _| _| _| _| _| _| _| _| _|";
    currData[2] = "|_ |_ |_ |_ |_ |_ |_ |_ |_ ";
    nums = scanNumbers(currData);
    assert(nums == [2,2,2,2,2,2,2,2,2]);
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = " _| _| _| _| _| _| _| _| _|";
    currData[2] = " _| _| _| _| _| _| _| _| _|";
    nums = scanNumbers(currData);
    assert(nums == [3,3,3,3,3,3,3,3,3]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "333393333");
    currData[0] = "                           ";
    currData[1] = "|_||_||_||_||_||_||_||_||_|";
    currData[2] = "  |  |  |  |  |  |  |  |  |";
    nums = scanNumbers(currData);
    assert(nums == [4,4,4,4,4,4,4,4,4]);
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = "|_ |_ |_ |_ |_ |_ |_ |_ |_ ";
    currData[2] = " _| _| _| _| _| _| _| _| _|";
    nums = scanNumbers(currData);
    assert(nums == [5,5,5,5,5,5,5,5,5]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "555555555 AMB ['555655555', '559555555']");
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = "|_ |_ |_ |_ |_ |_ |_ |_ |_ ";
    currData[2] = "|_||_||_||_||_||_||_||_||_|";
    nums = scanNumbers(currData);
    assert(nums == [6,6,6,6,6,6,6,6,6]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "666666666 AMB ['666566666', '686666666']");
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = "  |  |  |  |  |  |  |  |  |";
    currData[2] = "  |  |  |  |  |  |  |  |  |";
    nums = scanNumbers(currData);
    assert(nums == [7,7,7,7,7,7,7,7,7]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "777777177");
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = "|_||_||_||_||_||_||_||_||_|";
    currData[2] = "|_||_||_||_||_||_||_||_||_|";
    nums = scanNumbers(currData);
    assert(nums == [8,8,8,8,8,8,8,8,8]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "888888888 AMB ['888886888', '888888880', '888888988']");
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = "|_||_||_||_||_||_||_||_||_|";
    currData[2] = " _| _| _| _| _| _| _| _| _|";
    nums = scanNumbers(currData);
    assert(nums == [9,9,9,9,9,9,9,9,9]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "999999999 AMB ['899999999', '993999999', '999959999']");
    currData[0] = "    _  _     _  _  _  _  _ ";
    currData[1] = "  | _| _||_||_ |_   ||_||_|";
    currData[2] = "  ||_  _|  | _||_|  ||_| _|";
    nums = scanNumbers(currData);
    assert(nums == [1,2,3,4,5,6,7,8,9]);
    currData[0] = " _  _  _  _  _  _  _  _    ";
    currData[1] = "| || || || || || || ||_   |";
    currData[2] = "|_||_||_||_||_||_||_| _|  |";
    nums = scanNumbers(currData);
    assert(nums == [0,0,0,0,0,0,0,5,1]);
    currData[0] = "    _  _  _  _  _  _     _ ";
    currData[1] = "|_||_|| || ||_   |  |  | _ ";
    currData[2] = "  | _||_||_||_|  |  |  | _|";
    nums = scanNumbers(currData);
    assert(nums == [4,9,0,0,6,7,7,1,-1]);
    assert(nums.validScan() == Status.ILLEGAL);
    currData[0] = "    _  _     _  _  _  _  _ ";
    currData[1] = "  | _| _||_| _ |_   ||_||_|";
    currData[2] = "  ||_  _|  | _||_|  ||_| _ ";
    nums = scanNumbers(currData);
    assert(nums == [1,2,3,4,-1,6,7,8,-1]);
    assert(nums.validScan() == Status.ILLEGAL);
    currData[0] = " _  _  _  _  _  _  _  _  _ ";
    currData[1] = " _|| || || || || || || || |";
    currData[2] = "|_ |_||_||_||_||_||_||_||_|";
    nums = scanNumbers(currData);
    assert(nums == [2,0,0,0,0,0,0,0,0]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "200800000");
    currData[0] = "    _  _  _  _  _  _     _ ";
    currData[1] = "|_||_|| || ||_   |  |  ||_ ";
    currData[2] = "  | _||_||_||_|  |  |  | _|";
    nums = scanNumbers(currData);
    assert(nums == [4,9,0,0,6,7,7,1,5]);
    assert(nums.validScan() == Status.ERROR);
    assert(currData.getNumber() == "490067715 AMB ['490067115', '490067719', '490867715']");
    currData[0] = "    _  _     _  _  _  _  _ ";
    currData[1] = " _| _| _||_||_ |_   ||_||_|";
    currData[2] = "  ||_  _|  | _||_|  ||_| _|";
    nums = scanNumbers(currData);
    assert(nums == [-1,2,3,4,5,6,7,8,9]);
    assert(nums.validScan() == Status.ILLEGAL);
    assert(currData.getNumber() == "123456789");
    currData[0] = " _     _  _  _  _  _  _    ";
    currData[1] = "| || || || || || || ||_   |";
    currData[2] = "|_||_||_||_||_||_||_| _|  |";
    nums = scanNumbers(currData);
    assert(nums == [0,-1,0,0,0,0,0,5,1]);
    assert(nums.validScan() == Status.ILLEGAL);
    assert(currData.getNumber() == "000000051");
    currData[0] = "    _  _  _  _  _  _     _ ";
    currData[1] = "|_||_|| ||_||_   |  |  | _ ";
    currData[2] = "  | _||_||_||_|  |  |  | _|";
    nums = scanNumbers(currData);
    assert(nums == [4,9,0,8,6,7,7,1,-1]);
    assert(nums.validScan() == Status.ILLEGAL);
    assert(currData.getNumber() == "490867715");
}
