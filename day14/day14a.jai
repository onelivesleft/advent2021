#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: x;  // x / _


Rule :: struct {
    pair : string;
    insertion : string;
}


main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    polymer : string;
    rules : [..] Rule;

    for line: line_split(data) {
        if !line  continue;
        if it_index == 0 {
            polymer = line;
        }
        else {
            rule : Rule;
            rule.pair, rule.insertion = split_into_two(line, " -> ");
            array_add(*rules, rule);
        }
    }

    process :: (polymer: string, rules: [] Rule) -> string {
        builder : String_Builder;
        init_string_builder(*builder);
        for i: 0 .. polymer.count - 2 {
            pair := substring(polymer, i, 2);
            append(*builder, pair[0]);
            for rule: rules {
                if rule.pair == pair {
                    append(*builder, rule.insertion);
                    break;
                }
            }
        }
        append(*builder, slice(polymer, -1));
        return builder_to_string(*builder);
    }

    outliers :: (polymer: string) -> least_common: int, most_common: int {
        table : [127] int;
        for split(polymer)  table[it] += 1;

        least : u8;  least_count := 9999999;
        most : u8;   most_count  := 0;
        for table {
            if it == 0  continue;
            c : u8 = xx it_index;
            if it < least_count {
                least_count = it;
                least = xx it_index;
            }
            if it > most_count {
                most_count = it;
                most = xx it_index;
            }
        }
        return least_count, most_count;
    }

    steps :: 10;

    for 1 .. steps  polymer = process(polymer, rules);

    least_common, most_common := outliers(polymer);
    print("% - % = %\n", most_common, least_common, most_common - least_common);
}


dummy :: #string __data
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
__data


input :: #string __data
NBOKHVHOSVKSSBSVVBCS

SN -> H
KP -> O
CP -> V
FN -> P
FV -> S
HO -> S
NS -> N
OP -> C
HC -> S
NP -> B
CF -> V
NN -> O
OS -> F
VO -> V
HK -> N
SV -> V
VC -> V
PH -> K
NH -> O
SB -> N
KS -> V
CB -> H
SS -> P
SP -> H
VN -> K
VP -> O
SK -> V
VF -> C
VV -> B
SF -> K
HH -> K
PV -> V
SO -> H
NK -> P
NO -> C
ON -> S
PB -> K
VS -> H
SC -> P
HS -> P
BS -> P
CS -> P
VB -> V
BP -> K
FH -> O
OF -> F
HF -> F
FS -> C
BN -> O
NC -> F
FC -> B
CV -> V
HN -> C
KF -> K
OO -> P
CC -> S
FF -> C
BC -> P
PP -> F
KO -> V
PC -> B
HB -> H
OB -> N
OV -> S
KH -> B
BO -> B
HV -> P
BV -> K
PS -> F
CH -> C
SH -> H
OK -> V
NB -> K
BF -> S
CO -> O
NV -> H
FB -> K
FO -> C
CK -> P
BH -> B
OH -> F
KB -> N
OC -> K
KK -> O
CN -> H
FP -> K
VH -> K
VK -> P
HP -> S
FK -> F
BK -> H
KV -> V
BB -> O
KC -> F
KN -> C
PO -> P
NF -> P
PN -> S
PF -> S
PK -> O
__data
