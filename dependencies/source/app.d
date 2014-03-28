import std.algorithm;
import std.stdio;

struct Dependencies
{
    char[][char] allDeps;

    void add(char dep, char[] deps)
    {
        this.allDeps[dep] = deps;
    }

    char[] get(char dep)
    {
        bool[char] deps;
        foreach (c; this.allDeps[dep])
        {
            deps[c] = false;
        }
        bool addedNew = true;
        while (addedNew)
        {
            addedNew = false;
            foreach (k; deps.keys)
            {
                if (k in this.allDeps)
                {
                    foreach (newKey; this.allDeps[k])
                    {
                        if (newKey !in deps)
                        {
                            deps[newKey] = false;
                            addedNew = true;
                        }
                    }
                }
            }
        }
        return deps.keys.sort;
    }
}

void main()
{
    Dependencies deps;
    deps.add('A', ['B', 'C']);
    deps.add('B', ['C', 'E']);
    deps.add('C', ['G']);
    deps.add('D', ['A', 'F']);
    deps.add('E', ['F']);
    deps.add('F', ['H']);

    assert(equal(['B', 'C', 'E', 'F', 'G', 'H'], deps.get('A')));
    assert(equal(['C', 'E', 'F', 'G', 'H'], deps.get('B')));
    assert(equal(['G'], deps.get('C')));
    assert(equal(['A', 'B', 'C', 'E', 'F', 'G', 'H'], deps.get('D')));
    assert(equal(['F', 'H'], deps.get('E')));
    assert(equal(['H'], deps.get('F')));

    Dependencies deps2;
    deps.add('A', ['B']);
    deps.add('B', ['C']);
    deps.add('C', ['A']);

    assert(equal(['A', 'B', 'C'], deps.get('A')));
}
