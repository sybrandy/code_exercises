import std.algorithm;
import std.array;
import std.conv;
import std.stdio;

enum Suit { HEARTS, SPADES, DIAMONDS, CLUBS };
enum CardValue { TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN,
                 JACK, QUEEN, KING, ACE };
immutable string[9] ranks = ["Nothing", "Pair", "Two Pair", "Three of a Kind",
                             "Straight", "Flush", "Full House",
                             "Four of a Kind", "Straight Flush"];

struct Card
{
    Suit suit;
    CardValue value;

    this(Suit suit, CardValue value)
    {
        this.suit = suit;
        this.value = value;
    }
}

Card[] toCards(string hand)
{
    Card[] cards;
    Suit[char] suitMap = ['H': Suit.HEARTS, 'S': Suit.SPADES,
                          'D': Suit.DIAMONDS, 'C': Suit.CLUBS];
    CardValue[string] cardMap = ["2": CardValue.TWO, "3": CardValue.THREE,
                                 "4": CardValue.FOUR, "5": CardValue.FIVE,
                                 "6": CardValue.SIX, "7": CardValue.SEVEN,
                                 "8": CardValue.EIGHT, "9": CardValue.NINE,
                                 "T": CardValue.TEN, "J": CardValue.JACK,
                                 "Q": CardValue.QUEEN, "K": CardValue.KING,
                                 "A": CardValue.ACE];
    foreach (h; hand.split())
    {
        Card newCard;
        newCard.value = cardMap[to!(string)(h[0])];
        newCard.suit = suitMap[h[1]];
        cards ~= newCard;
    }
    return cards.sort!((a,b) => a.value < b.value).array;
}

unittest
{
    Card[5] cards = toCards("2H 3D 5S 9C KD");
    assert(cards[0].suit == Suit.HEARTS);
    assert(cards[0].value == CardValue.TWO);
    assert(cards[1].suit == Suit.DIAMONDS);
    assert(cards[1].value == CardValue.THREE);
    assert(cards[2].suit == Suit.SPADES);
    assert(cards[2].value == CardValue.FIVE);
    assert(cards[3].suit == Suit.CLUBS);
    assert(cards[3].value == CardValue.NINE);
    assert(cards[4].suit == Suit.DIAMONDS);
    assert(cards[4].value == CardValue.KING);

    cards = toCards("TH QD AS JC 4D");
    assert(cards[0].suit == Suit.DIAMONDS);
    assert(cards[0].value == CardValue.FOUR);
    assert(cards[1].suit == Suit.HEARTS);
    assert(cards[1].value == CardValue.TEN);
    assert(cards[2].suit == Suit.CLUBS);
    assert(cards[2].value == CardValue.JACK);
    assert(cards[3].suit == Suit.DIAMONDS);
    assert(cards[3].value == CardValue.QUEEN);
    assert(cards[4].suit == Suit.SPADES);
    assert(cards[4].value == CardValue.ACE);
}

auto isFlush = (Card[] hand)
                => hand.map!(a => a.suit)().array.sort.uniq.array.length == 1;

unittest
{
    assert(isFlush(toCards("TH QD AS JC 4D")) == false);
    assert(isFlush(toCards("TH QH AH JH 4H")) == true);
}

bool isStraight(Card[] hand)
{
    CardValue[] values = hand.map!(a => a.value).array;

    if (isPair(hand) || isTwoPair(hand) || isThree(hand))
    {
        return false;
    }
    // Need to handle A,2,3,4,5 straights as well.
    if (values[4] == CardValue.ACE && values[3] == CardValue.FIVE)
    {
        return values[3] - values[0] == 3;
    }

    return values[4] - values[0] == 4;
}

unittest
{
    assert(isStraight(toCards("2C 3H 4S 6H 5C")) == true);
    assert(isStraight(toCards("AC KH QS JH TC")) == true);
    assert(isStraight(toCards("2C KH 4S 6H 5C")) == false);
    assert(isStraight(toCards("2C 3H 4S AH 5C")) == true);
    assert(isStraight(toCards("5H 5C 5D AS 2H")) == false);
    assert(isStraight(toCards("2H 5C 5D AS 2H")) == false);
}

int getPairs(Card[] hand)
{
    CardValue[] values = hand.map!(a => a.value).array.sort.uniq.array;

    int numPairs;
    foreach (v; values)
    {
        if (count!((a,b) => a.value == b)(hand, v) == 2)
        {
            numPairs++;
        }
    }
    return numPairs;
}

int getTriples(Card[] hand)
{
    CardValue[] values = hand.map!(a => a.value).array.sort.uniq.array;

    int numTriples;
    foreach (v; values)
    {
        if (count!((a,b) => a.value == b)(hand, v) == 3)
        {
            numTriples++;
        }
    }
    return numTriples;
}

// One pair
auto isPair = (Card[] hand) => getPairs(hand) == 1 && getTriples(hand) == 0;

unittest
{
    assert(isPair(toCards("2C KH 4S 6H 5C")) == false);
    assert(isPair(toCards("2C KH 6S 6H KC")) == false);
    assert(isPair(toCards("2C KH 4S 6H KC")) == true);
    assert(isPair(toCards("2C KH KS 6H KC")) == false);
    assert(isPair(toCards("6C KH KS 6H KC")) == false);
    assert(isPair(toCards("KC KH KS 6H KC")) == false);
}

// Two pair
auto isTwoPair = (Card[] hand) => getPairs(hand) == 2;

unittest
{
    assert(isTwoPair(toCards("2C KH 4S 6H 5C")) == false);
    assert(isTwoPair(toCards("2C KH 6S 6H KC")) == true);
    assert(isTwoPair(toCards("2C KH 4S 6H KC")) == false);
    assert(isTwoPair(toCards("2C KH KS 6H KC")) == false);
    assert(isTwoPair(toCards("6C KH KS 6H KC")) == false);
    assert(isTwoPair(toCards("KC KH KS 6H KC")) == false);
}

// Three of a kind.
auto isThree = (Card[] hand) => getTriples(hand) == 1 && getPairs(hand) == 0;

unittest
{
    assert(isThree(toCards("2C KH 4S 6H 5C")) == false);
    assert(isThree(toCards("2C KH 6S 6H KC")) == false);
    assert(isThree(toCards("2C KH 4S 6H KC")) == false);
    assert(isThree(toCards("2C KH KS 6H KC")) == true);
    assert(isThree(toCards("6C KH KS 6H KC")) == false);
    assert(isThree(toCards("KC KH KS 6H KC")) == false);
}

// Four of a kind.
auto isFour = (Card[] hand)
              => hand.map!(a => a.value).array.sort.uniq.array.length == 2 &&
                 getTriples(hand) == 0;

unittest
{
    assert(isFour(toCards("2C KH 4S 6H 5C")) == false);
    assert(isFour(toCards("2C KH 6S 6H KC")) == false);
    assert(isFour(toCards("2C KH 4S 6H KC")) == false);
    assert(isFour(toCards("2C KH KS 6H KC")) == false);
    assert(isFour(toCards("6C KH KS 6H KC")) == false);
    assert(isFour(toCards("KC KH KS 6H KC")) == true);
}

// Full House
auto isFull = (Card[] hand) => getTriples(hand) == 1 && getPairs(hand) == 1;

unittest
{
    assert(isFull(toCards("2C KH 4S 6H 5C")) == false);
    assert(isFull(toCards("2C KH 6S 6H KC")) == false);
    assert(isFull(toCards("2C KH 4S 6H KC")) == false);
    assert(isFull(toCards("2C KH KS 6H KC")) == false);
    assert(isFull(toCards("6C KH KS 6H KC")) == true);
    assert(isFull(toCards("KC KH KS 6H KC")) == false);
}

int handRank(Card[] currCards)
{
    if (isFlush(currCards) && isStraight(currCards))
    {
        return 8;
    }

    if (isFour(currCards))
    {
        return 7;
    }

    if (isFull(currCards))
    {
        return 6;
    }

    if (isFlush(currCards))
    {
        return 5;
    }

    if (isStraight(currCards))
    {
        return 4;
    }

    if (isThree(currCards))
    {
        return 3;
    }

    if (isTwoPair(currCards))
    {
        return 2;
    }

    if (isPair(currCards))
    {
        return 1;
    }
    return 0;
}

unittest
{
    assert(handRank(toCards("5H 6H 7H 8H 9H")) == 8);
    assert(handRank(toCards("5H 5C 5D 5S 2H")) == 7);
    assert(handRank(toCards("5H 5C 5D 2S 2H")) == 6);
    assert(handRank(toCards("5H 6H 3H 8H 2H")) == 5);
    assert(handRank(toCards("5H 6C 7S 8D 9H")) == 4);
    assert(handRank(toCards("5H 5C 5D AS 2H")) == 3);
    assert(handRank(toCards("5H 5C 2D AS 2H")) == 2);
    assert(handRank(toCards("4H 5C 2D AS 2H")) == 1);
    assert(handRank(toCards("4H 5C 8D AS 2H")) == 0);
}

auto getHighCard = (Card[] c) => c.map!(a => a.value)()
                                  .reduce!((a,b) => (a > b) ? a : b);

unittest
{
    assert(getHighCard(toCards("5H 6H 7H 8H 9H")) == CardValue.NINE);
    assert(getHighCard(toCards("TH 6H 7H 8H 9H")) == CardValue.TEN);
    assert(getHighCard(toCards("5H KH 7H 8H 9H")) == CardValue.KING);
    assert(getHighCard(toCards("5H KH 7H AH 9H")) == CardValue.ACE);
}

auto getLowCard = (Card[] c) => c.map!(a => a.value)()
                                 .reduce!((a,b) => (a < b) ? a : b);

unittest
{
    assert(getLowCard(toCards("5H 6H 7H 8H 9H")) == CardValue.FIVE);
    assert(getLowCard(toCards("TH 6H 7H 8H 9H")) == CardValue.SIX);
    assert(getLowCard(toCards("5H KH 7H 8H 9H")) == CardValue.FIVE);
    assert(getLowCard(toCards("5H KH 7H AH 9H")) == CardValue.FIVE);
}

int pickWinner(string hand1, string hand2)
{
    Card[] cards1 = toCards(hand1);
    Card[] cards2 = toCards(hand2);
    int rank1 = handRank(cards1);
    int rank2 = handRank(cards2);

    if (rank1 > rank2)
    {
        return 1;
    }
    else if (rank2 > rank1)
    {
        return 2;
    }

    if ((rank1 == 8 && rank2 == 8) || (rank1 == 4 && rank2 == 4))
    {
        int low1 = getLowCard(cards1);
        int low2 = getLowCard(cards2);

        return (low1 > low2) ? 1 : (low2 > low1) ? 2 : 0;
    }

    Card[] diff1 = setDifference!((a,b) => a.value < b.value)(cards1, cards2).array;
    Card[] diff2 = setDifference!((a,b) => a.value < b.value)(cards2, cards1).array;

    if (diff1.empty && diff2.empty)
    {
        return 0;
    }

    CardValue high1 = getHighCard(diff1);
    CardValue high2 = getHighCard(diff2);

    return (high1 > high2) ? 1 : 2;
}

unittest
{
    assert(pickWinner("5H 6H 7H 8H 9H", "5S 6H 7H 8H 9H") == 1);
    assert(pickWinner("4S 6H 7H 8H 9H", "5S 6H 7H 8H 9H") == 2);
    assert(pickWinner("4S 6H 7H 8H 9H", "4D 6C 7C 8C 9C") == 0);
    assert(pickWinner("4S 6H 7H 8H 9H", "5S 6H 3H 8H 9H") == 1);
    assert(pickWinner("4S 6H 7H 8H 9H", "5S 6H TH 8H 9H") == 2);
    assert(pickWinner("5H 6H 7H 8H 9H", "5H 6H 7H 8H 4H") == 1);
    assert(pickWinner("5H 6H 7H 3H 4H", "5H 6H 7H 8H 4H") == 2);
    assert(pickWinner("5H 6H 7H 8H 9H", "5H 6H 7H 8H 9H") == 0);

    // Sample test cases
    assert(pickWinner("2H 3D 5S 9C KD", "2C 3H 4S 8C AH") == 2);
    assert(pickWinner("2H 4S 4C 2D 4H", "2S 8S AS QS 3S") == 1);
    assert(pickWinner("2H 3D 5S 9C KD", "2C 3H 4S 8C KH") == 1);
    assert(pickWinner("2H 3D 5S 9C KD", "2D 3H 5C 9S KH") == 0);
}

version(unittest)
{
    void main()
    {
        writeln("Executing unit tests.");
    }
}
