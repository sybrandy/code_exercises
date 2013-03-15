import std.algorithm;
import std.array;
import std.stdio;

void main()
{
}

immutable double bookCost = 8.0;
immutable double[4] discounts = [.05, .10, .20, .25];

double price(int[] books)
{
    double cost = 0.0;
    if (books.length == 0)
    {
        cost = 0;
    }
    else if (books.length == 1)
    {
        cost = bookCost;
    }
    else if (books.length > 1 && books.uniq.array.length == 1)
    {
        cost = bookCost * books.length;
    }
    else if (books.length == books.uniq.array.length)
    {
        // Subtracting 2 from length as a length of 2 means we get the first
        // discount, which is index 0.
        double discount = 1 - discounts[books.length-2];
        cost = (bookCost * books.length) * discount;
    }
    else
    {
        int[] uniqBooks = books.uniq.array;
        int[5] bookCounts;
        foreach (b; uniqBooks)
        {
            bookCounts[b] = books.count(b);
        }

        foreach (p; Permutation(books.length, uniqBooks.length))
        {
            int[] currCounts = bookCounts.dup;
            double tempCost = 0.0;
            for (int i = 0; i < p.length; i++)
            {
                int[] currBooks;
                foreach (b; uniqBooks)
                {
                    if (currCounts[b])
                    {
                        currBooks ~= b;
                        currCounts[b]--;
                    }
                    if (currBooks.length == p[i])
                    {
                        break;
                    }
                }
                if (currBooks.length < p[i])
                {
                    tempCost = cost;
                    break;
                }
                double discount = (currBooks.length > 1)
                                ? 1 - discounts[currBooks.length-2]
                                : 1;
                tempCost += (bookCost * currBooks.length) * discount;
            }
            if (cost > tempCost || cost == 0.0)
            {
                /*writeln("Permuation: ", p);*/
                cost = tempCost;
            }
        }
    }
    /*writeln("Cost: ", cost);*/
    return cost;
}

unittest
{
    // Simple cost calculations
    assert(0 == price([]));
    assert(8 == price([0]));
    assert(8 == price([1]));
    assert(8 == price([2]));
    assert(8 == price([3]));
    assert(8 == price([4]));
    assert(8 * 2 == price([0, 0]));
    assert(8 * 3 == price([1, 1, 1]));

    // Simple discounts.
    assert(8 * 2 * .95 == price([0,1]));
    assert(8 * 3 * .9 == price([0,2,4]));
    assert(8 * 4 * .8 == price([0,1,2,4]));
    assert(8 * 5 * .75 == price([0,1,2,3,4]));

    // Multiple discounts.
    assert(8 + (8 * 2 * .95) == price([0,0,1]));
    assert(2 * (8 * 2 * .95) == price([0,0,1,1]));
    assert((8 * 4 * .8) + (8 * 2 * .95) == price([0,0,1,2,2,3]));
    assert(8 + (8 * 5 * .75) == price([0,1,1,2,3,4]));

    // Edge Cases
    assert(2 * (8 * 4 * .8) == price([0,0,1,1,2,2,3,4]));
    assert((3 * (8 * 5 * .75)) + (2 * (8 * 4 * .8)) ==
           price([0,0,0,0,0,
                  1,1,1,1,1,
                  2,2,2,2,
                  3,3,3,3,3,
                  4,4,4,4]));
}

struct Permutation
{
    private int numElems;
    private int maxElems;
    private int[] permutation;

    this(int a, int b)
    {
        numElems = a;
        maxElems = b;
        permute();
    }

    @property int[] front()
    {
        return permutation.dup;
    }

    @property void popFront()
    {
        permute();
    }

    @property bool empty()
    {
        return permutation.length == numElems;
    }

    private void permute()
    {
        if (permutation.length > 0)
        {
            /*
                Algorithm:
                - Find the lowest index of the smallest element.
                - Find the highest index of the first element where the diff
                  between the element and the smallest element is > 1.
                  - If such an element is found, subtract 1 from the high
                    elemement and add it to the smallest element.
                  - If such an element is not found, append 1 to the end of
                    the array and subtract 1 from the element with the
                    hightest index that is > 1.
             */
            int[] currPerm = permutation.dup;
            int smallestIndex = currPerm.length - 1;
            for (int i = currPerm.length - 2; i >= 0; i--)
            {
                if (currPerm[i] != currPerm[smallestIndex])
                {
                    break;
                }
                smallestIndex = i;
            }

            int diffIndex = -1;
            for (int i = smallestIndex - 1; i >= 0; i--)
            {
                if ((currPerm[i] - currPerm[smallestIndex]) > 1)
                {
                    diffIndex = i;
                    break;
                }
            }

            if (diffIndex > -1)
            {
                currPerm[smallestIndex]++;
                currPerm[diffIndex]--;
            }
            else
            {
                currPerm ~= 1;
                for (int i = currPerm.length - 2; i >= 0; i--)
                {
                    if ((currPerm[i] - 1) > 0)
                    {
                        diffIndex = i;
                        break;
                    }
                }
                currPerm[diffIndex]--;
            }
            permutation = currPerm;
        }
        else
        {
            int sum;
            while (sum != numElems)
            {
                if ((numElems - sum) > maxElems)
                {
                    permutation ~= maxElems;
                    sum += maxElems;
                }
                else
                {
                    int diff = numElems - sum;
                    permutation ~= diff;
                    sum += diff;
                }
            }
        }
    }
}

unittest
{
    Permutation p = Permutation(2, 2);
    assert(equal(p.front, [2]));
    p.popFront();
    assert(p.empty());

    p = Permutation(23, 5);
    assert(equal(p.front, [5,5,5,5,3]));
    p.popFront();
    assert(equal(p.front, [5,5,5,4,4]));

    /*
    p = Permutation(23, 5);
    for (int i = 0; i < 12; i++)
    {
        writeln(p.front);
        p.popFront();
    }
    */
}
