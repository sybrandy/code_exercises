import std.algorithm;
import std.array;
import std.container;
import std.random;
import std.stdio;

debug
{
    import std.string;
}

enum Suit { HEARTS, SPADES, DIAMONDS, CLUBS };
enum CardValue { ACE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN,
                 JACK, QUEEN, KING };

struct Card
{
    Suit suit;
    CardValue value;
    bool visible;

    bool equals(Card c)
    {
        return this.suit == c.suit &&
               this.value == c.value &&
               this.visible == c.visible;
    }
}

struct Move
{
    Card[] cards;
    int fromStack;
    int toStack;
    bool toFoundation;
    bool newCard;
    bool fromPile;
    bool restartPile;
    bool pileEmpty;

    bool equals(Move m)
    {
        if (this is m) return true;
        return (equal!((a, b) => a.equals(b))(this.cards, m.cards)) &&
               (this.fromStack == m.fromStack) &&
               (this.toStack == m.toStack) &&
               (this.toFoundation == m.toFoundation) &&
               (this.newCard == m.newCard) &&
               (this.fromPile == m.fromPile) &&
               (this.restartPile == m.restartPile) &&
               (this.pileEmpty == m.pileEmpty);
    }
}

unittest
{
    Card c1;
    c1.suit = Suit.HEARTS;
    c1.value = CardValue.ACE;
    c1.visible = true;
    Card c2;
    c2.suit = Suit.HEARTS;
    c2.value = CardValue.ACE;
    c2.visible = true;

    Move m1;
    m1.cards ~= c1;
    Move m2;
    m2.cards ~= c2;
    assert(m1.equals(m2));

    m2.fromPile = true;
    assert(!m1.equals(m2));

    Move e1, e2;
    e1.restartPile = true;
    e2.restartPile = true;
    assert(e1.equals(e2));
}

// CTFE Rocks!
immutable Card[52] deck = createDeck();

pure Card[52] createDeck()
{
    Card[52] deck;
    foreach (suit; [Suit.HEARTS, Suit.SPADES, Suit.DIAMONDS, Suit.CLUBS])
    {
        int offset = suit * 13;
        foreach (value; [ CardValue.ACE, CardValue.TWO, CardValue.THREE,
                          CardValue.FOUR, CardValue.FIVE, CardValue.SIX,
                          CardValue.SEVEN, CardValue.EIGHT, CardValue.NINE,
                          CardValue.TEN, CardValue.JACK, CardValue.QUEEN,
                          CardValue.KING])
        {
            deck[offset + value].suit = suit;
            deck[offset + value].value = value;
            deck[offset + value].visible = false;
        }
    }
    return deck;
}

void main()
{
    version(unittest)
    {
        writeln("Executing unit tests.");
    }
    else
    {
        int[string] numWins = ["play1":0];
        int numTries = 100000;
        Array!(Card)[4] foundations;
        Array!(Card)[6] tableau;
        /*int i = 18;*/
        for (int i = 0; i < numTries; i++)
        {
            Array!(Card) currDeck = shuffle(i);
            foundations[0].clear;
            foundations[1].clear;
            foundations[2].clear;
            foundations[3].clear;

            tableau[0].clear;
            tableau[1].clear;
            tableau[2].clear;
            tableau[3].clear;
            tableau[4].clear;
            tableau[5].clear;

            Array!(Card) pile = deal(currDeck, tableau);

            debug
            {
                writeln("Current deal: ", i);
                printCards(currDeck, "current deck");
                printCards(tableau, "tableau");
                printCards(pile, "pile");
                printCards(foundations, "foundations");
                // 52 - 21 = 31
                writeln("Cards in pile: ", pile.length, "\n");
            }

            if (play1(pile, foundations, tableau))
            {
                writeln("Won!");
                numWins["play1"]++;
            }
            else
            {
                writeln("Lost...");
            }
        }

        foreach (k; numWins.keys.sort)
        {
            writefln("Number of winds for %s: %d", k, numWins[k]);
        }
    }
}

Array!(Card) shuffle(int seed)
{
    Mt19937 gen;
    /*gen.seed(unpredictableSeed);*/
    gen.seed(seed);
    bool[52] seen;
    Array!(Card) cards;

    cards.length = 52;
    for (int setCards = 0; setCards < cards.length; )
    {
        int nextCard = uniform(0, cards.length, gen);
        if (!seen[nextCard])
        {
            cards[setCards] = deck[nextCard];
            seen[nextCard] = true;
            setCards++;
        }
    }
    return cards;
}

Array!(Card) deal(Array!(Card) localDeck, ref Array!(Card)[6] tableau)
{
    uint count;
    Array!(Card) rest;
    debug { printCards(localDeck, "localDeck"); }
    for (uint i = 0, start = 0; start < 6; start++)
    {
        for (int j = start; j < 6; j++, i++)
        {
            Card temp = localDeck[count++];
            if (start == j) temp.visible = true;
            tableau[j].insert(temp);
        }
    }
    foreach (c; localDeck[count..$])
    {
        rest.insert(c);
    }
    return rest;
}

auto isRed = (Card a) => a.suit == Suit.HEARTS || a.suit == Suit.DIAMONDS;
auto isBlack = (Card a) => a.suit == Suit.SPADES || a.suit == Suit.CLUBS;

bool validPlace(Card top, Card bottom)
{
    if ((top.isBlack && bottom.isBlack) ||
        (top.isRed && bottom.isRed))
    {
        /*writeln("Suit colors match.");*/
        return false;
    }

    if ((bottom.value - top.value) != 1)
    {
        /*writeln("Values too far apart: ", cast(int)(bottom.value - top.value));*/
        return false;
    }
    return true;
}

unittest
{
    Card a;
    Card b;

    a.suit = Suit.HEARTS;
    a.value = CardValue.ACE;
    b.suit = Suit.DIAMONDS;
    b.value = CardValue.TWO;
    assert(isRed(a));
    assert(isRed(b));
    assert(isBlack(a) == false);
    assert(isBlack(b) == false);
    assert(validPlace(a, b) == false);

    b.suit = Suit.CLUBS;
    assert(isBlack(b));
    assert(isRed(b) == false);
    assert(validPlace(a, b) == true);

    a.value = CardValue.TEN;
    assert(validPlace(a, b) == false);

    b.value = CardValue.KING;
    assert(validPlace(a, b) == false);
}

bool play1(Array!(Card) inPile, Array!(Card)[4] inFoundations, Array!(Card)[6] inTableau)
{
    /*Card[] pile = inPile.dup;*/
    Array!Card pile = inPile.dup;
    Array!Card stack;
    Array!(Card)[4] foundations = inFoundations.dup;
    Array!(Card)[6] tableau = inTableau.dup;
    Array!Move moves;
    bool gameLost;
    bool gameWon;
    int numMoves;
    int pileIdx;

    while (!gameLost && !gameWon)
    {
        // First, scan the tableau to see if we can move cards to the foundation
        // or move cards to other stacks in the tableau.
        debug(stats)
        {
            writefln("Stats: \t%d\t%d\t%d", pile.length, stack.length,
                     moves.length);
            writeln("Moving cards to foundations.");
        }
        debug
        {
            printCards(tableau, "tableau");
            printCards(foundations, "foundations");
        }
        moveCardsToFoundation(tableau, foundations, moves);
        debug
        {
            printCards(tableau, "tableau");
            printCards(foundations, "foundations");
            printMoves(moves);
        }
        debug(stats)
        {
            writeln("Moving cards to tableau.");
        }
        moveCardsInTableau(tableau, moves);
        debug
        {
            printCards(tableau, "tableau");
            printMoves(moves);
            printCards(pile, "pile");
            writeln("Pile index: ", pileIdx);
        }

        // Next, flip one card and see if we can place it in the foundation or the
        // tableau.
        Move currMove = Move();
        if (pile.length > 0)
        {
            stack ~= pile[pileIdx++];
            currMove.newCard = true;
            currMove.cards ~= stack[$-1];
        }
        else
        {
            currMove.pileEmpty = true;
        }
        moves ~= currMove;
        debug
        {
            printCards(stack, "stack");
            printMoves(moves);
        }
        moveStackCards(stack, tableau, foundations, moves);
        debug
        {
            printMoves(moves);
            printCards(tableau, "tableau");
            printCards(foundations, "foundations");
            printCards(pile, "pile");
            printCards(stack, "stack");
        }

        if (pileIdx == pile.length)
        {
            pile = stack.dup;
            stack.clear();
            currMove = Move();
            currMove.restartPile = true;
            moves ~= currMove;
            pileIdx = 0;
        }

        // Last, check to see if we have won or lost the game.
        // To win: the pile is empty and the tableau is empty OR each stack in the
        // foundation contains 13 cards.
        // To lose: detect to see if the same moves are being repeated.
        if (moves.length == numMoves)
        {
            writeln("No moves performed!");
            return false;
        }
        numMoves = moves.length;
        /*if (numMoves > 2000)*/
        /*if (numMoves > 45)*/
        /*
        {
            writeln("Too many moves!");
            return false;
        }
        */
        debug(stats)
        {
            writeln("Checking win/loss.");
        }
        gameLost = repeatMoves(moves);
        gameWon = winGame(cast(Card[][])tableau);
    }

    // Return true if we win, false if we don't.
    return gameWon;
}

auto winGame = (Card[][] f) => (count!(a => a.length == 13)(f) == 4);

unittest
{
    Card[][] t;
    t.length = 4;
    assert(!winGame(t));
    t[0].length = 13;
    assert(!winGame(t));
    t[1].length = 13;
    assert(!winGame(t));
    t[2].length = 13;
    assert(!winGame(t));
    t[3].length = 13;
    assert(winGame(t));
}

// Fix and get unit tests working!
bool repeatMoves(Array!(Move) moves)
{
    if (moves.length == 0)
    {
        return false;
    }

    Move lastMove = moves[$-1];

    debug
    {
        writeln("Number of times we see the last move: ", count!((a, b) => a.equals(b))(moves[], lastMove));
        printMove(lastMove);
    }
    if (count!((a, b) => a.equals(b))(moves[], lastMove) == 1)
    {
        debug { writeln("Only see the move once."); }
        return false;
    }

    int prevIndex;
    for (int i = moves.length - 2; i > 0; i--)
    {
        if (lastMove.equals(moves[i]))
        {
            prevIndex = i;
            break;
        }
    }

    int diff = moves.length - prevIndex - 1;
    debug
    {
        writeln("Set of moves: ", moves[prevIndex+1..$]);
        writeln("Previous index: ", prevIndex);
        writeln("Size of set: ", moves[prevIndex+1..$].length);
        writeln("Total moves: ", moves.length);
        writeln("Diff: ", diff);
    }

    int lastIndex = moves.length - 1;
    for (int i = prevIndex; i > 0; i--)
    {
        if (moves[i].equals(lastMove) && prevIndex >= diff)
        {
            int numEqual;
            for (int j = lastIndex; j > prevIndex; j--)
            {
                debug
                {
                    writefln("Indices: %d - %d", i - (lastIndex - j), j);
                    writeln("Comparing moves:");
                    printMove(moves[i - (lastIndex - j)]);
                    printMove(moves[j]);
                    writeln("Same: ", moves[i - (lastIndex - j)].equals(moves[j]));
                }
                if (moves[i - (lastIndex - j)].equals(moves[j]))
                {
                    numEqual++;
                }
            }
            if (numEqual == (diff))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    return false;
}

unittest
{
    Array!Move testMoves;
    Card card1;
    card1.value = CardValue.TEN;
    card1.suit = Suit.CLUBS;
    card1.visible = true;
    Move move1;
    move1.cards ~= card1;
    move1.fromStack = 5;
    move1.toStack = 4;
    testMoves.insert(move1);
    Card card2 = card1;
    card2.value = CardValue.NINE;
    card2.suit = Suit.HEARTS;
    Move move2;
    move2.cards ~= card2;
    move2.fromPile = true;
    move2.toStack = 4;
    testMoves.insert(move2);
    Card card3 = card1;
    card3.value = CardValue.EIGHT;
    card3.suit = Suit.SPADES;
    Move move3;
    move3.cards ~= card3;
    move3.fromPile = true;
    move3.toStack = 4;
    testMoves.insert(move3);
    Move move4;
    move4.newCard = true;
    testMoves.insert(move4);

    assert(!repeatMoves(testMoves));

    move4.newCard = false;
    move4.restartPile = true;
    testMoves[3] = move4;
    assert(!repeatMoves(testMoves));

    testMoves.clear();
    move1 = Move();
    move1.newCard = true;
    testMoves.insert(move1);
    move2 = Move();
    move2.restartPile = true;
    testMoves.insert(move2);
    move3 = Move();
    move3.newCard = true;
    move3.cards ~= card1;
    testMoves.insert(move3);
    move4 = Move();
    move4.newCard = true;
    testMoves.insert(move4);
    Move move5 = Move();
    move5.restartPile = true;
    testMoves.insert(move5);
    Move move6 = Move();
    move6.newCard = true;
    Card card5 = card1;
    move6.cards ~= card5;
    testMoves.insert(move6);
    assert(repeatMoves(testMoves));

    /*
    Move[8] eightMoves;
    eightMoves[0].newCard = true;
    eightMoves[1].newCard = true;
    eightMoves[2].cards ~= card1;
    eightMoves[2].fromPile = true;
    eightMoves[2].toStack = 3;
    eightMoves[3].newCard = true;
    eightMoves[4].restartPile = true;
    eightMoves[5].newCard = true;
    eightMoves[6].newCard = true;
    eightMoves[7].restartPile = true;
    assert(!repeatMoves(eightMoves));
    */
}

void moveCardsToFoundation(ref Array!(Card)[6] tableau, ref Array!(Card)[4] foundations,
                           ref Array!(Move) moves)
{
    int numMoves = 1;
    while (numMoves > 0)
    {
        numMoves = 0;
        for (int i = 0; i < tableau.length; i++)
        {
            bool cardMoved = false;
            if (tableau[i].length == 0)
            {
                continue;
            }

            if (tableau[i][$-1].value == CardValue.ACE)
            {
                debug(fine) { writeln("Found an ACE!"); }
                for (int j = 0; j < foundations.length; j++)
                {
                    if (foundations[j].length == 0)
                    {
                        foundations[j] ~= tableau[i][$-1];
                        break;
                    }
                }
                cardMoved = true;
            }
            else
            {
                debug(fine) { writeln("Checking other cards."); }
                for (int j = 0; j < foundations.length; j++)
                {
                    if (foundations[j].length == 0)
                    {
                        continue;
                    }
                    if (tableau[i][$-1].suit == foundations[j][0].suit &&
                        (tableau[i][$-1].value - 1) == foundations[j][$-1].value)
                    {
                        foundations[j] ~= tableau[i][$-1];
                        cardMoved = true;
                    }
                }
            }

            if (cardMoved)
            {
                Move currMove;
                currMove.cards ~= tableau[i][$-1];
                currMove.toFoundation = true;
                currMove.fromStack = i;
                moves ~= currMove;
                tableau[i].stableRemoveBack();
                if (tableau[i].length > 0)
                {
                    Card temp = tableau[i][$-1];
                    temp.visible = true;
                    tableau[i][$-1] = temp;
                }
                numMoves++;
            }
        }
    }
    debug { writeln("End of moving cards to the foundation."); }
}

void moveCardsInTableau(ref Array!(Card)[6] tableau, ref Array!(Move) moves)
{
    int numMoves = 1;
    while (numMoves > 0)
    {
        debug(stats)
        {
            writeln("Moves in tableau: ", moves.length);
            writeln("Length of tableau: ", tableau.length);
        }
        numMoves = 0;
        for (int i = 0; i < tableau.length; i++)
        {
            debug(fine){ writeln("Current i: ", i); }
            if (tableau[i].length == 0 || tableau[i][0].value == CardValue.KING)
            {
                continue;
            }

            int cardIndex = tableau[i].length - 1;
            debug(fine){ writeln("Initial cardIndex: ", cardIndex); }
            while (cardIndex > 0)
            {
                if (tableau[i][cardIndex-1].visible)
                {
                    cardIndex--;
                }
                else
                {
                    break;
                }
            }
            debug(fine){ writeln("New cardIndex: ", cardIndex); }

            for (int j = tableau.length - 1; j >= 0; j--)
            {
                debug(fine)
                {
                    writeln("Current j: ", j);
                    writeln(tableau[i][cardIndex]);
                    if (tableau[j].length == 0)
                    {
                        writefln("Tableau[%d] is empty.", j);
                    }
                    else
                    {
                        writeln(tableau[j][$-1]);
                    }
                }
                if (tableau[j].length == 0 &&
                    tableau[i][cardIndex].value != CardValue.KING)
                {
                    debug(fine) { writeln("Compating to empty tableau."); }
                    continue;
                }
                if (i != j &&
                    ((tableau[j].length == 0 &&
                      tableau[i][cardIndex].value == CardValue.KING) ||
                     validPlace(tableau[i][cardIndex], tableau[j][$-1])))
                {
                    tableau[j] ~= tableau[i][cardIndex..$];
                    Move currMove;
                    currMove.cards = cast(Card[])tableau[i][cardIndex..tableau[i].length].array;
                    currMove.fromStack = i;
                    currMove.toStack = j;
                    debug(fine)
                    {
                        write("Current move: ");
                        printMove(currMove);
                    }
                    moves ~= currMove;
                    numMoves++;
                    tableau[i].stableRemoveBack(currMove.cards.length);
                    cardIndex--;
                    debug(fine){ writeln("New cardIndex: ", cardIndex); }
                    if (cardIndex >= 0)
                    {
                        Card temp = tableau[i][tableau[i].length - 1];
                        temp.visible = true;
                        tableau[i][tableau[i].length - 1] = temp;
                    }
                    break;
                }
            }
        }

        debug(stats)
        {
            writeln("Number of moves in the past iteration: ", numMoves);
        }
        if (repeatMoves(moves))
        {
            debug { writeln("Caught repeating moves when we shouldn't."); }
            break;
        }
    }
    debug { writeln("End of moving cards in the tableau."); }
}

void moveStackCards(ref Array!Card stack, ref Array!(Card)[6] tableau,
                    ref Array!(Card)[4] foundations, ref Array!(Move) moves)
{
    int stackIdx = stack.length;
    int numMoves = 1;

    while (numMoves > 0 && stackIdx > 0)
    {
        stackIdx--;
        numMoves = 0;
        bool cardMoved = false;

        // First, check to see if the card can be put on the foundation.
        if (stack[stackIdx].value == CardValue.ACE)
        {
            debug(fine) { writeln("Found an ACE!"); }
            for (int j = 0; j < foundations.length; j++)
            {
                if (foundations[j].length == 0)
                {
                    foundations[j] ~= stack[stackIdx];
                    break;
                }
            }
            cardMoved = true;
        }
        else
        {
            debug(fine) { writeln("Checking other cards."); }
            for (int j = 0; j < foundations.length; j++)
            {
                if (foundations[j].length == 0)
                {
                    continue;
                }
                if (stack[stackIdx].suit == foundations[j][0].suit &&
                    (stack[stackIdx].value - 1) == foundations[j][$-1].value)
                {
                    foundations[j] ~= stack[stackIdx];
                    cardMoved = true;
                }
            }
        }

        // Second, see if the card can be placed on a tableau.
        if (cardMoved)
        {
            Move currMove;
            currMove.cards ~= stack[stackIdx];
            currMove.toFoundation = true;
            currMove.fromPile = true;
            moves ~= currMove;
            numMoves++;
        }
        else
        {
            for (int j = tableau.length - 1; j >= 0; j--)
            {
                if (tableau[j].length == 0 &&
                    stack[stackIdx].value != CardValue.KING)
                {
                    continue;
                }
                debug(fine)
                {
                    writeln("Current j: ", j);
                    writeln(stack[stackIdx]);
                    writeln(tableau[j][$-1]);
                }
                if ((tableau[j].length == 0 &&
                     stack[stackIdx].value == CardValue.KING) ||
                    validPlace(stack[stackIdx], tableau[j][$-1]))
                {
                    Card temp = stack[stackIdx];
                    temp.visible = true;
                    tableau[j] ~= temp;
                    Move currMove;
                    currMove.cards ~= stack[stackIdx];
                    currMove.fromPile = true;
                    currMove.toStack = j;
                    moves ~= currMove;
                    numMoves++;
                    break;
                }
            }
        }
    }

    if ((stack.length > 0) && (stackIdx < (stack.length - 1)))
    {
        stack.stableRemoveBack(stack.length - stackIdx);
    }
    debug { writeln("Done moving stack cards."); }
}

debug
{
    void printCards(Array!(Card)[] cards, string name)
    {
        writeln(name.capitalize);
        for (int i = 0; i < cards.length; i++)
        {
            writeln("Row ", i);
            foreach (c; cards[i])
            {
                writeln("-- ", c);
            }
        }
        writeln();
    }

    void printCards(Array!Card cards, string name)
    {
        writeln(name.capitalize);
        foreach (c; cards[])
        {
            writeln(c);
        }
        writeln();
    }

    void printCards(Card[] cards, string name)
    {
        writeln(name.capitalize);
        foreach (c; cards)
        {
            writeln(c);
        }
        writeln();
    }

    void printMoves(Array!(Move) moves)
    {
        writeln("Moves: ", moves.length);
        foreach (m; moves[])
        {
            printMove(m);
        }
        writeln();
    }

    void printMove(Move m)
    {
        writeln("Move:");
        writeln("\tCards: ", m.cards);
        writeln("\tFrom stack: ", m.fromStack);
        writeln("\tTo stack: ", m.toStack);
        writeln("\tTo foundation: ", m.toFoundation);
        writeln("\tNew Card: ", m.newCard);
        writeln("\tFrom pile: ", m.fromPile);
        writeln("\tRestart pile: ", m.restartPile);
    }
}

debug(fine)
{
    void printMove(Move m)
    {
        writeln("Move:");
        writeln("\tCards: ", m.cards);
        writeln("\tFrom stack: ", m.fromStack);
        writeln("\tTo stack: ", m.toStack);
        writeln("\tTo foundation: ", m.toFoundation);
        writeln("\tNew Card: ", m.newCard);
        writeln("\tFrom pile: ", m.fromPile);
        writeln("\tRestart pile: ", m.restartPile);
    }
}
