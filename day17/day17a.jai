#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: x;  // x / _

x0, x1 : int;
y0, y1 : int;

main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    for line: line_split(data) {
        prefix :: "target area: ";
        assert(starts_with(line, prefix));
        tail := slice(line, prefix.count);
        x_string, y_string := split_into_two(tail, ", ");

        ok : bool;

        x0_string, x1_string := split_into_two(slice(x_string, 2), "..");
        x0, ok = parse_int(x0_string);  assert(ok);
        x1, ok = parse_int(x1_string);  assert(ok);

        y0_string, y1_string := split_into_two(slice(y_string, 2), "..");
        y0, ok = parse_int(y0_string);  assert(ok);
        y1, ok = parse_int(y1_string);  assert(ok);
    }

    can_reach :: (x: int) -> bool {
        total := 0;
        while x > 0 {
            total += x;
            x -= 1;
        }
        return total >= x0 && total <= x1;
    }

    min_x := 1;
    while !can_reach(min_x)  min_x += 1;

    max_x := min_x;
    while can_reach(max_x)  max_x += 1;
    max_x -= 1;

    best_vy := 0;
    best_y := 0;

    for starting_vy: 1 .. 1000{
        for starting_vx: min_x .. max_x {
            vx := starting_vx;
            vy := starting_vy;
            x := 0;
            y := 0;
            highest_y := 0;

            while y >= y0 {
                x += vx;
                if vx > 0  vx -= 1;
                y += vy;
                vy -= 1;
                if y > highest_y  highest_y = y;

                if x >= x0 && x <= x1 && y >= y0 && y <= y1 && highest_y > best_y {
                    best_y = highest_y;
                    best_vy = starting_vy;
                }
            }
        }
    }

    print("Y: %, VY: %\n", best_y, best_vy);
}


dummy :: #string __data
target area: x=20..30, y=-10..-5
__data


input :: #string __data
target area: x=207..263, y=-115..-63
__data
