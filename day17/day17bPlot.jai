#import "Basic";
#import "Plot";
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

    total_initial_velocities := 0;

    window_height :: 700;
    plot_start(300, window_height);

    translate :: (x: int, y: int) -> int, int {
        return x + 20, window_height - (y + 200);
    }

    {
        tx0, ty0 := translate(-100, 0);
        tx1, ty1 := translate(400, 0);
        print("% %\n", ty0, ty1);
        line(tx0, ty0, tx1, ty1, colors.white);
    }

    plot :: (x: int, y: int) {
        tx, ty := translate(x, y);
        plot(tx, ty, colors.cyan);
    }

    Point :: struct {
        x, y : int;
    }

    points : [..] Point;

    for starting_vy: y0 .. 114 { // 114 from part a
        for starting_vx: min_x .. x1 {
            vx := starting_vx;
            vy := starting_vy;
            x := 0;
            y := 0;

            array_reset(*points);

            while y >= y0 {
                x += vx;
                if vx > 0  vx -= 1;
                y += vy;
                vy -= 1;

                point := array_add(*points);
                point.x = x;
                point.y = y;

                if x >= x0 && x <= x1 && y >= y0 && y <= y1 {
                    for points  plot(it.x, it.y);
                    continue starting_vx;
                }
            }
        }
    }

    plot_done();
}


dummy :: #string __data
target area: x=20..30, y=-10..-5
__data


input :: #string __data
target area: x=207..263, y=-115..-63
__data
