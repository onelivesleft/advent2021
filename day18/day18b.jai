#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: x;  // x / _


Pair :: struct {
    union {
        x_int: int;
        x_pair: *Pair;
    }
    union {
        y_int: int;
        y_pair: *Pair;
    }
    parent : *Pair;
    x_is_int : bool;
    y_is_int : bool;
}

new_pair :: (parent : *Pair = null) -> *Pair {
    pair := New(Pair, allocator=temp);
    pair.parent = parent;
    return pair;
}


main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    read_pair :: (pair_string: string, parent: *Pair = null) -> *Pair {
        pair := new_pair(parent);

        remainder := slice(pair_string, 1, -1);
        {
            c := remainder[0];
            if c >= #char "0" && c <= #char "9" {
                pair.x_is_int = true;
                pair.x_int = c - #char "0";
                assert(remainder[1] == #char ",");
                remainder = slice(remainder, 2);
            }
            else {
                assert(c == #char "[", "Why is c %?", char_as_string(*c));
                pair.x_is_int = false;
                start, end := match_bracket(remainder);
                pair.x_pair = read_pair(start, pair);
                remainder = end;
                assert(remainder[0] == #char ",", "Why is remainder[0] %?", char_as_string(*remainder[0]));
                remainder = slice(end, 1);
            }
        }

        {
            c := remainder[0];
            if c >= #char "0" && c <= #char "9" {
                pair.y_is_int = true;
                pair.y_int = c - #char "0";
            }
            else {
                assert(c == #char "[", "Why is c %?", char_as_string(*c));
                pair.y_is_int = false;
                start, end := match_bracket(remainder);
                pair.y_pair = read_pair(start, pair);
            }
        }

        return pair;
    }

    match_bracket :: (s: string) -> string, string {
        bracket_count := 1;
        for 1 .. s.count - 1 {
            c := s[it];
            if c == #char "["       bracket_count += 1;
            else if c == #char "]"  bracket_count -= 1;
            if bracket_count == 0  return slice(s, 0, it + 1), slice(s, it + 1);
        }
        assert(false);  return "", "";
    }

    to_string :: (pair: *Pair, depth := 0) -> string {
        RESET   :: "\e[m";
        EXPLODE :: "\e[0;31m";
        SPLIT   :: "\e[0;32m";


        builder : String_Builder;
        if depth == 4 append(*builder, EXPLODE);
        append(*builder, "[");
        if pair.x_is_int {
            if pair.x_int >= 10 append(*builder, SPLIT);
            print_to_builder(*builder, "%", pair.x_int);
            if pair.x_int >= 10 append(*builder, RESET);
        }
        else {
            print_to_builder(*builder, "%", to_string(pair.x_pair, depth + 1));
        }
        append(*builder, ",");
        if pair.y_is_int {
            if pair.y_int >= 10 append(*builder, SPLIT);
            print_to_builder(*builder, "%", pair.y_int);
            if pair.y_int >= 10 append(*builder, RESET);
        }
        else {
            print_to_builder(*builder, "%", to_string(pair.y_pair, depth + 1));
        }
        append(*builder, "]");
        if depth == 4 append(*builder, RESET);
        return builder_to_string(*builder);
    }


    add :: (a: *Pair, b: *Pair, do_reduce := true) -> *Pair {
        pair := new_pair();
        pair.x_pair = a;
        pair.y_pair = b;
        a.parent = pair;
        b.parent = pair;

        if do_reduce
            while reduce(pair) {}

        return pair;
    }

    is_x_child :: (parent: *Pair, pair: *Pair) -> bool {
        return !parent.x_is_int && parent.x_pair == pair;
    }

    is_y_child :: (parent: *Pair, pair: *Pair) -> bool {
        return !parent.y_is_int && parent.y_pair == pair;
    }

    are_x_of_parent :: (using pair: *Pair) -> bool {
        return !parent.x_is_int && parent.x_pair == pair;
    }

    are_y_of_parent :: (using pair: *Pair) -> bool {
        return !parent.y_is_int && parent.y_pair == pair;
    }

    value_to_left_of_x :: (pair: *Pair, from: *Pair) -> *int {
        if is_x_child(pair, from) {
            if !pair.parent  return null;
            else             return value_to_left_of_x(pair.parent, pair);
        }
        else {
            if pair.x_is_int  return *pair.x_int;
            else              return last_y_value(pair.x_pair);
        }
    }

    value_to_right_of_y :: (pair: *Pair, from: *Pair) -> *int {
        if is_y_child(pair, from) {
            if !pair.parent  return null;
            else             return value_to_right_of_y(pair.parent, pair);
        }
        else {
            if pair.y_is_int  return *pair.y_int;
            else              return first_x_value(pair.y_pair);
        }
    }

    first_x_value :: (pair: *Pair) -> *int {
        if pair.x_is_int  return *pair.x_int;
        else              return first_x_value(pair.x_pair);
    }

    last_y_value :: (pair: *Pair) -> *int {
        if pair.y_is_int  return *pair.y_int;
        else              return last_y_value(pair.y_pair);
    }

    reduce :: (using pair: *Pair) -> did_something: bool{
        explode :: (using pair: *Pair, depth := 0) -> did_something: bool {
            if depth == 4 {
                assert(x_is_int && y_is_int, "%", to_string(pair));
                left, right : *int;
                if are_x_of_parent(pair) {
                    left = value_to_left_of_x(parent, pair);

                    if parent.y_is_int  right = *parent.y_int;
                    else                right = first_x_value(parent.y_pair);

                    parent.x_is_int = true;
                    parent.x_int = 0;
                }
                else {
                    assert(parent.x_is_int);
                    left = *parent.x_int;

                    right = value_to_right_of_y(parent, pair);

                    parent.y_is_int = true;
                    parent.y_int = 0;
                }

                if left  { <<left  += x_int; }
                if right { <<right += y_int; }

                return true;
            }

            if !x_is_int && explode(x_pair, depth + 1)  return true;
            if !y_is_int && explode(y_pair, depth + 1)  return true;

            return false;
        }

        split :: (using pair: *Pair) -> did_something: bool {
            split_value :: (v: int, pair: *Pair) {
                pair.x_is_int = true;
                pair.x_int = v / 2;
                pair.y_is_int = true;
                pair.y_int = v - pair.x_int;
                diff := pair.y_int - pair.x_int;
                assert(diff == 0 || diff == 1);
            }

            if x_is_int && x_int >= 10 {
                v := x_int;
                x_is_int = false;
                x_pair = new_pair(pair);
                split_value(v, x_pair);
                return true;
            }

            if !x_is_int && split(x_pair)  return true;

            if y_is_int && y_int >= 10 {
                v := y_int;
                y_is_int = false;
                y_pair = new_pair(pair);
                split_value(v, y_pair);
                return true;
            }

            if !y_is_int && split(y_pair)  return true;

            return false;
        }

        return explode(pair) || split(pair);
    }

    magnitude :: (pair: *Pair) -> int {
        total := 0;

        if pair.x_is_int  total += pair.x_int * 3;
        else              total += magnitude(pair.x_pair) * 3;

        if pair.y_is_int  total += pair.y_int * 2;
        else              total += magnitude(pair.y_pair) * 2;

        return total;
    }

    pairs : [..] *Pair;
    pairs.allocator = temp;

    line_count := 0;
    for line_split(data)  line_count += 1;

    largest_magnitude := 0;

    for index_a: 0 .. line_count - 1 {
        for index_b: 0 .. line_count - 1 {
            if index_a == index_b  continue;

            array_reset(*pairs);
            reset_temporary_storage();
            for line: line_split(data) {
                array_add(*pairs, read_pair(line));
            }

            pair := add(pairs[index_a], pairs[index_b]);
            m := magnitude(pair);
            if m > largest_magnitude  largest_magnitude = m;
        }
    }

    print("Largest Magnitude = %\n", largest_magnitude);
}


operator== :: (a: Pair, b: Pair) -> bool {
    if a.x_is_int {
        if !b.x_is_int || a.x_int != b.x_int  return false;
    }
    else{
        if <<a.x_pair != <<b.x_pair return false;
    }

    if a.y_is_int {
        if !b.y_is_int || a.y_int != b.y_int  return false;
    }
    else{
        if <<a.y_pair != <<b.y_pair return false;
    }

    return true;
}


reductions :: #string __data
[[[[[9,8],1],2],3],4]
[7,[6,[5,[4,[3,2]]]]]
[[6,[5,[4,[3,2]]]],1]
[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]
[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]
__data

simple :: #string __data
[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]
__data

simple_answer :: #string __data
[0,0]
[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]
[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]
[[[[7,0],[7,7]],[[7,7],[7,8]]],[[[7,7],[8,8]],[[7,7],[8,7]]]]
[[[[7,7],[7,8]],[[9,5],[8,7]]],[[[6,8],[0,8]],[[9,9],[9,0]]]]
[[[[6,6],[6,6]],[[6,0],[6,7]]],[[[7,7],[8,9]],[8,[8,1]]]]
[[[[6,6],[7,7]],[[0,7],[7,7]]],[[[5,5],[5,6]],9]]
[[[[7,8],[6,7]],[[6,8],[0,8]]],[[[7,7],[5,0]],[[5,5],[5,6]]]]
[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]
[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]
__data

dummy :: #string __data
[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
__data


input :: #string __data
[[[7,1],2],3]
[[1,7],7]
[[6,8],[[6,[3,6]],[0,5]]]
[[[[2,1],8],[[9,4],8]],[[6,5],4]]
[[1,[[3,8],[9,1]]],[[9,1],[[1,7],0]]]
[[[7,4],[8,[7,6]]],[9,[[6,3],[7,8]]]]
[[[[5,0],1],4],[[5,[6,9]],[[4,3],2]]]
[[[3,8],8],[[[3,2],8],[9,[0,5]]]]
[[[[5,8],[3,9]],[7,[1,4]]],[6,1]]
[3,[[[3,3],9],[0,7]]]
[[[6,9],1],[[0,[8,4]],[[2,2],9]]]
[[[[6,2],3],[0,4]],3]
[[[[3,8],7],[[7,4],0]],[2,[5,[2,8]]]]
[[4,[9,[8,0]]],[[1,5],[[9,3],8]]]
[[[8,5],[3,[1,4]]],[[6,[8,0]],[[2,7],[2,6]]]]
[4,7]
[[[[2,3],0],[[1,9],[4,1]]],[[1,[4,2]],3]]
[[[8,[5,3]],[[5,7],7]],[[5,6],[6,4]]]
[[[[2,4],1],[8,6]],[[6,5],[0,[9,1]]]]
[[[1,[5,7]],8],[[[9,1],9],[[1,2],4]]]
[[[[5,5],[4,0]],[4,[9,6]]],[[[2,1],1],7]]
[[[[1,9],[9,5]],[[5,0],[3,1]]],[[[6,7],[8,8]],[[7,3],0]]]
[[6,[[6,7],[9,0]]],[[7,7],[[0,3],0]]]
[[0,6],[5,2]]
[[[[5,8],3],[[9,0],8]],[7,4]]
[[0,[[9,9],[9,4]]],[[[1,1],2],[1,[6,7]]]]
[0,[[5,7],2]]
[[2,[[5,4],6]],[1,[8,[7,6]]]]
[[[1,7],[8,[5,8]]],[[[2,1],[9,1]],[[5,6],9]]]
[[1,8],[9,[4,3]]]
[5,[2,[[5,5],9]]]
[3,[8,[[2,8],[4,8]]]]
[[[4,9],[[5,5],0]],[9,[8,[3,0]]]]
[[[2,[6,4]],[8,[9,9]]],[[[0,4],8],[3,[9,7]]]]
[[[[8,1],[2,4]],3],[1,[[3,3],[6,3]]]]
[[[8,[7,3]],[1,8]],2]
[[8,[8,4]],[[6,[4,7]],[3,0]]]
[[[[4,6],[8,3]],9],[9,[[8,9],[0,9]]]]
[[3,[[2,7],[4,4]]],2]
[8,[[[8,6],2],[[8,9],6]]]
[[[[5,7],[2,0]],[[0,2],[5,5]]],[[[8,5],5],[[1,3],[2,3]]]]
[[1,6],[[9,8],[9,[4,9]]]]
[[[[1,4],5],9],[4,[6,8]]]
[[[[6,4],[9,0]],[[1,4],[6,6]]],[[9,[2,8]],2]]
[[[[5,9],2],[[0,0],5]],[2,1]]
[6,[[3,2],[[3,0],0]]]
[[[[7,4],1],[[4,1],1]],[[3,4],4]]
[3,[9,[9,7]]]
[[[3,[3,3]],[0,3]],[1,[1,8]]]
[[8,[8,7]],[[9,2],5]]
[[[1,[3,9]],[5,9]],[1,5]]
[[[[7,8],[9,7]],9],[[[9,2],[2,2]],[[9,6],8]]]
[4,[[3,5],[[1,3],[5,5]]]]
[7,[[[0,1],2],[[3,6],5]]]
[0,[[[2,4],[3,4]],[8,9]]]
[[1,[[6,8],1]],[8,0]]
[1,1]
[7,0]
[[1,2],[[0,[8,3]],[[4,5],[9,7]]]]
[[[[2,3],[5,9]],[7,[1,9]]],2]
[[3,5],[[9,7],9]]
[[[[6,9],[4,8]],6],0]
[[[[2,4],[3,9]],[2,[9,4]]],[[[8,9],[3,1]],7]]
[[5,[[0,2],4]],[[[9,9],[7,4]],[1,5]]]
[3,[6,[[5,4],1]]]
[[[2,[2,7]],2],[[4,[7,3]],5]]
[7,[[0,[2,0]],[[9,4],6]]]
[[4,[3,[6,2]]],9]
[[[0,[5,6]],[8,3]],[[7,9],[0,[9,6]]]]
[8,[[6,4],[4,8]]]
[[[8,[6,8]],[5,[7,3]]],[[[7,8],5],2]]
[[[[3,5],[4,7]],5],[[0,0],[9,[1,9]]]]
[[7,[[1,5],9]],[[[3,4],[1,7]],[1,[7,9]]]]
[[0,[3,[4,1]]],[[[2,9],3],[4,[0,8]]]]
[[[8,[1,6]],[[0,1],7]],[[[1,1],[0,2]],[[9,4],[9,6]]]]
[[[[6,7],0],[[6,8],9]],[[1,[6,6]],[[2,9],[4,7]]]]
[[[[5,0],[1,2]],[1,[5,1]]],[[0,4],1]]
[[9,1],6]
[[7,2],[[[5,5],[4,3]],6]]
[[9,[[0,6],9]],[[7,9],[7,1]]]
[[[[7,3],[6,4]],[[2,5],[7,2]]],[[[4,4],0],[[9,5],[8,5]]]]
[[[[8,8],[6,4]],[[0,2],[9,5]]],2]
[[[[3,0],7],[9,2]],[[0,[8,6]],[[7,2],[8,5]]]]
[[0,6],[1,[9,[4,3]]]]
[[0,8],[[[5,0],6],[5,[2,0]]]]
[[[[7,1],[0,3]],[[9,9],[3,5]]],[4,[8,4]]]
[7,[[1,[3,7]],[[3,4],[2,3]]]]
[[[[2,2],[4,8]],[[3,4],0]],[[[1,5],[2,8]],5]]
[6,[[[9,1],5],[9,9]]]
[[[2,[8,6]],[[9,9],[6,3]]],4]
[[[[3,2],[9,3]],8],9]
[[[[6,9],0],[[0,6],[1,3]]],[[5,[9,8]],[[1,5],[3,7]]]]
[[2,[4,[2,3]]],[[[6,0],[7,2]],3]]
[[[[8,3],4],[6,[8,8]]],4]
[[[9,8],5],[[[4,4],[6,3]],[8,6]]]
[9,2]
[[[3,4],[4,[7,0]]],[0,[4,[6,9]]]]
[[[0,8],[3,9]],[[[3,8],6],[[9,3],6]]]
[[[[5,6],[0,3]],1],[8,[2,9]]]
[[[[4,2],8],[[9,3],7]],0]
__data
