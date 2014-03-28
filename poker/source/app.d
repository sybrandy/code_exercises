import std.algorithm;
import std.array;
import std.stdio;
import std.string;

import hands;

immutable int[][] cardPerms = createPerms();
int[][] createPerms()
{
    int[][] perms;
    int[7] set = [1,2,3,4,5,6,7];
    int[5] perm = set[0..5];
    int idx = 1;

    // 1,2,3,4,5
    // 1,2,3,4,6
    // 1,2,3,4,7
    // 1,2,3,5,6
    // 1,2,3,5,7
    // 1,2,3,6,7
    // 1,2,4,5,6
    // 1,2,4,5,7
    // 1,2,4,6,7
    // 1,2,5,6,7
    while (perms.length == 0 || !equal(perms[$-1].dup, perm.dup))
    {
        perms ~= perm.dup;
        for (int i = 4; i >= 0; i--)
        {
            if (perm[i] != set[i+2])
            {
                if (i < perm.length-1 && perm[i+1] == set[i+3])
                {
                    perm[i]++;
                    for (int j = i+1; j < perm.length; j++)
                    {
                        perm[j] = perm[j-1] + 1;
                    }
                    break;
                }
                if (perm[i] < set[i+2])
                {
                    perm[i]++;
                    break;
                }
            }
        }
    }

    return perms;
}

void main()
{
    /*writeln("Number of permutations: ", cardPerms.length);*/
    /*foreach (p; cardPerms)*/
    /*{*/
    /*    writeln("Permutation: ", p);*/
    /*}*/

    string[] hands;
    foreach (hand; stdin.byLine().map!(a => a.toUpper()))
    {
        hands ~= hand.idup;
    }

    int[] handRank;
    foreach (hand; hands)
    {
        handRank ~= getRank(hand);
    }
    int maxRank = reduce!((a,b) => (a > b) ? a : b)(handRank);

    writeln("Hands: ", hands);
    writeln("Ranks: ", handRank);
    writeln("Max Rank: ", maxRank);

    for (int i = 0; i < handRank.length; i++)
    {
        if (handRank[i] > 0 && handRank[i] == maxRank)
        {
            writefln("%s %s (winner)", hands[i], ranks[handRank[i]]);
        }
        else if (handRank[i] > 0)
        {
            writefln("%s %s", hands[i], ranks[handRank[i]]);
        }
        else
        {
            writeln(hands[i]);
        }
    }
}

int getRank(string hand)
{
    string[] cards = hand.split();

    if (cards.length < 7)
    {
        return -1;
    }

    int rank;
    foreach (perm; cardPerms)
    {
        int newRank = handRank(getSubHand(cards, perm));
        rank = (newRank > rank) ? newRank : rank;
    }

    return rank;
}

Card[] getSubHand(string[] cards, immutable int[] perm)
{
    string[] subCards;

    foreach (p; perm)
    {
        subCards ~= cards[p - 1];
    }
    return toCards(subCards.join(" "));
}
