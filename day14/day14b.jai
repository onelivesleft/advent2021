#import "Basic";
#import "Math";
#import "Strings";
#import "Time";
#load "../utils.jai";

confirm_test :: x;  // x / _


Pair :: [2] u8;

pair :: (s: string) -> Pair {
    assert(s.count == 2);
    result : Pair;
    result[0] = s[0];
    result[1] = s[1];
    return result;
}


Rule :: struct {
    pair : Pair;
    insertion : u8;
}


Memo :: struct {
    step: u8 = ---;
    pair : Pair = ---;
    _ : u8;

    #place step;
    key: u32;
}

Result :: struct {
    exists : bool;
    values : [26] int;
}

memos : [10000000] Result;

polymer : string;
rules : [..] Rule;


main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    for line: line_split(data) {
        if !line  continue;
        if it_index == 0 {
            polymer = line;
        }
        else {
            rule : Rule;
            pair_string, insertion_string := split_into_two(line, " -> ");
            rule.pair = pair(pair_string);
            rule.insertion = insertion_string[0];
            array_add(*rules, rule);
        }
    }

    process_pairs :: (p: Pair, step: u8) -> Result {
        if step == 0  return .{};

        memo : Memo;
        memo.step = step;
        memo.pair = p;
        result := memos[memo.key];
        if result.exists  return result;

        defer {
            result.exists = true;
            memos[memo.key] = result;
        }

        for rule: rules {
            if rule.pair[0] == p[0] && rule.pair[1] == p[1] {
                left, right : Pair;
                left[0] = p[0];
                left[1] = rule.insertion;
                right[0] = rule.insertion;
                right[1] = p[1];
                result = process_pairs(left, step - 1);
                other := process_pairs(right, step - 1);
                for 0 .. 25  result.values[it] += other.values[it];
                result.values[rule.insertion - #char "A"] += 1;
                break;
            }
        }

        return result;
    }

    outliers :: (table: [] int) -> least_common: int, most_common: int {
        least : u8;  least_count := S64_MAX;
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

    memset(memos.data, 0, size_of(type_of(memos)));

    steps : u8 : 40;

    totals : Result;

    for i: 0 .. polymer.count - 2 {
        p := pair(substring(polymer, i, 2));
        result := process_pairs(p, steps);
        for 0 .. 25  totals.values[it] += result.values[it];
    }

    for split(polymer)  totals.values[it - #char "A"] += 1;

    least_common, most_common := outliers(totals.values);
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
