#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: x;  // x / _

octopi : [..] [..] u8;
flashed : [..] [..] bool;


main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;


    make_row :: (value: $T) -> [..] T { result : [..] T; return result; }
    add_dummy :: (array: *[..] u8)   { array_add(array, 0); }
    add_dummy :: (array: *[..] bool) { array_add(array, false); }

    array_add(*octopi, make_row(cast(u8)0));
    array_add(*flashed, make_row(false));

    for line: line_split(data) {
        octopi_row := make_row(cast(u8)0);
        flashed_row := make_row(false);
        add_dummy(*octopi_row);
        add_dummy(*flashed_row);
        for split(line) {
            array_add(*octopi_row, it - #char "0");
            array_add(*flashed_row, false);
        }
        add_dummy(*octopi_row);
        add_dummy(*flashed_row);
        array_add(*octopi, octopi_row);
        array_add(*flashed, flashed_row);
    }

    array_add(*octopi, make_row(cast(u8)0));
    array_add(*flashed, make_row(false));

    column_count := octopi[1].count;
    row_count := octopi.count;
    last_column_index := column_count - 2;
    last_row_index := row_count - 2;

    for 1 .. column_count {
        add_dummy(*octopi[0]);
        add_dummy(*octopi[last_row_index + 1]);
        add_dummy(*flashed[0]);
        add_dummy(*flashed[last_row_index + 1]);
    }

    increase_energy_levels :: () #expand {
        for y: 1 .. `last_row_index
            for x: 1 .. `last_column_index
                octopi[y][x] += 1;
    }

    simulate_flashes :: () -> int #expand {
        flashes := 0;

        for y: 1 .. `last_row_index {
            for x: 1 .. `last_column_index {
                if octopi[y][x] > 9 && !flashed[y][x] {
                    flashed[y][x] = true;
                    flashes += 1;
                    for ty: y - 1 .. y + 1
                        for tx: x - 1 .. x + 1
                            octopi[ty][tx] += 1;
                }
            }
        }

        return flashes;
    }

    cleanup :: () -> bool #expand {
        n_sync := true;
        for y: 1 .. `last_row_index {
            for x: 1 .. `last_column_index {
                if flashed[y][x] {
                    flashed[y][x] = false;
                    octopi[y][x] = 0;
                }
                else {
                    n_sync = false;
                }
            }
        }
        return n_sync;
    }

    dump :: () #expand {
        for y: 1 .. `last_row_index {
            for x: 1 .. `last_column_index
                print("%", formatInt(min(10, octopi[y][x]), base=16));
            print(" ");
            for x: 1 .. `last_column_index
                print("%", ifx flashed[y][x] then "O" else ".");
            print("\n");
        }
        print("\n");
    }

    n_sync := false;
    step := 0;
    while !n_sync {
        increase_energy_levels();
        flashes := simulate_flashes();
        while flashes {
            flashes = simulate_flashes();
        }
        n_sync = cleanup();
        step += 1;
    }

    print("%\n", step);
}


dummy :: #string __data
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
__data


input :: #string __data
1172728874
6751454281
2612343533
1884877511
7574346247
2117413745
7766736517
4331783444
4841215828
6857766273
__data
