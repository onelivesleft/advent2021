#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: _;  // x / _


main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    for line: line_split(data) {
        // command, unit_string := split_into_two(line, #char " ");
        // assert(command != "");
        // assert(unit_string != "");
        // units, ok := parse_int(unit_string);
        // assert(ok);
    }

    print("%\n", @result@);
}


dummy :: #string __data
__data


input :: #string __data
__data
