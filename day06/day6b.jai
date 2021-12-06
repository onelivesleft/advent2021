#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: x;  // x / _
verbose :: false;


fish : [9] int;
fish_head := 0;

main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    for split(data, #char ",") {
        timer, ok := parse_int(it);
        assert(ok);
        fish[timer] += 1;
    }

    simulate :: () #expand {
        births := fish[fish_head];
        reset_index := (fish_head + 7) % fish.count;
        birth_index := (fish_head + 9) % fish.count;
        fish[fish_head] = 0;
        fish[reset_index] += births;
        fish[birth_index] += births;
        fish_head = (fish_head + 1) % fish.count;
    }

    days :: 256;

    #if verbose  print("Initial state: %\n", sprint_fish());

    for 1 .. days {
        simulate();
        #if verbose  print("After % days: %\n", formatInt(it, minimum_digits=2), sprint_fish());
    }

    total_fish := 0;
    for fish  total_fish += it;

    print("\nTotal fish = %\n", total_fish);
}

sprint_fish :: () -> string {
    builder : String_Builder;
    init_string_builder(*builder);
    for 0 .. fish.count - 1 {
        i := (fish_head + it) % fish.count;
        if it  append(*builder, " ");
        print_to_builder(*builder, "%", fish[i]);
    }
    return builder_to_string(*builder);
}


make_32 :: (value: u8) -> string {
    return sprint("u8.[%1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1];", value);
}

/*
3,4,3,1,2     = 0 1 1 2 1
2,3,2,0,1     = 1 1 2 1
1,2,1,6,0,8   = 1 2 1 0 0 0 1 0 1
                1 2 1 0 0 1 0 1 0
*/

dummy :: #string __data
3,4,3,1,2
__data


input :: #string __data
1,2,5,1,1,4,1,5,5,5,3,4,1,2,2,5,3,5,1,3,4,1,5,2,5,1,4,1,2,2,1,5,1,1,1,2,4,3,4,2,2,4,5,4,1,2,3,5,3,4,1,1,2,2,1,3,3,2,3,2,1,2,2,3,1,1,2,5,1,2,1,1,3,1,1,5,5,4,1,1,5,1,4,3,5,1,3,3,1,1,5,2,1,2,4,4,5,5,4,4,5,4,3,5,5,1,3,5,2,4,1,1,2,2,2,4,1,2,1,5,1,3,1,1,1,2,1,2,2,1,3,3,5,3,4,2,1,5,2,1,4,1,1,5,1,1,5,4,4,1,4,2,3,5,2,5,5,2,2,4,4,1,1,1,4,4,1,3,5,4,2,5,5,4,4,2,2,3,2,1,3,4,1,5,1,4,5,2,4,5,1,3,4,1,4,3,3,1,1,3,2,1,5,5,3,1,1,2,4,5,3,1,1,1,2,5,2,4,5,1,3,2,4,5,5,1,2,3,4,4,1,4,1,1,3,3,5,1,2,5,1,2,5,4,1,1,3,2,1,1,1,3,5,1,3,2,4,3,5,4,1,1,5,3,4,2,3,1,1,4,2,1,2,2,1,1,4,3,1,1,3,5,2,1,3,2,1,1,1,2,1,1,5,1,1,2,5,1,1,4
__data
