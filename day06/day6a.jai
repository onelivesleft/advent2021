#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: x;  // x / _
verbose :: false;

fish : [..] u8;


main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    for split(data, #char ",") {
        timer, ok := parse_int(it);
        assert(ok);
        array_add(*fish, xx timer);
    }

    simulate :: () #expand {
        ones := #insert #run make_32(1);
        ones_ptr := ones.data;
        sixes := #insert #run make_32(6);
        sixes_ptr := sixes.data;

        fish_ptr := fish.data;
        new_fish := 0;
        end := fish.data + fish.count;
        simd_end := end - 32;

        #asm AVX,AVX2 {
            xorps   zero_vec:, zero_vec, zero_vec;
            pcmpeqb full_vec:, full_vec, full_vec;
            movdqu  one_vec:, [ones_ptr];
            movdqu  six_vec:, [sixes_ptr];
        }

        while fish_ptr < simd_end {
            births := 0;
            #asm AVX,AVX2 {
                movdqu fish_vec:, [fish_ptr];

                /* check for zeroes: zero = birth */
                pcmpeqb birth_vec:, fish_vec, zero_vec;
                pmovmskb birth_gpr:, birth_vec;
                popcnt births, birth_gpr; != 0

                /* decrement */
                psubb fish_vec, fish_vec, one_vec;

                /* reset relevant fish to 6 */
                pand reset_vec:, six_vec, birth_vec;
                xorps no_birth_vec:, birth_vec, full_vec;
                pand fish_vec, fish_vec, no_birth_vec;
                por fish_vec, fish_vec, reset_vec;
                movdqu [fish_ptr], fish_vec;
            }
            new_fish += births;
            fish_ptr += 32;
        }

        while fish_ptr < end {
            if <<fish_ptr == 0 {
                <<fish_ptr = 6;
                new_fish += 1;
            }
            else {
                <<fish_ptr -= 1;
            }
            fish_ptr += 1;
        }

        for 1 .. new_fish  array_add(*fish, 8);
    }

    days :: 80;

    #if verbose  print("Initial state: %\n", fish);

    for 1 .. days {
        simulate();
        #if verbose  print("After % days: %\n", formatInt(it, minimum_digits=2), fish);
    }

    print("\nTotal fish = %\n", fish.count);
}


make_32 :: (value: u8) -> string {
    return sprint("u8.[%1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1, %1];", value);
}


dummy :: #string __data
3,4,3,1,2
__data


input :: #string __data
1,2,5,1,1,4,1,5,5,5,3,4,1,2,2,5,3,5,1,3,4,1,5,2,5,1,4,1,2,2,1,5,1,1,1,2,4,3,4,2,2,4,5,4,1,2,3,5,3,4,1,1,2,2,1,3,3,2,3,2,1,2,2,3,1,1,2,5,1,2,1,1,3,1,1,5,5,4,1,1,5,1,4,3,5,1,3,3,1,1,5,2,1,2,4,4,5,5,4,4,5,4,3,5,5,1,3,5,2,4,1,1,2,2,2,4,1,2,1,5,1,3,1,1,1,2,1,2,2,1,3,3,5,3,4,2,1,5,2,1,4,1,1,5,1,1,5,4,4,1,4,2,3,5,2,5,5,2,2,4,4,1,1,1,4,4,1,3,5,4,2,5,5,4,4,2,2,3,2,1,3,4,1,5,1,4,5,2,4,5,1,3,4,1,4,3,3,1,1,3,2,1,5,5,3,1,1,2,4,5,3,1,1,1,2,5,2,4,5,1,3,2,4,5,5,1,2,3,4,4,1,4,1,1,3,3,5,1,2,5,1,2,5,4,1,1,3,2,1,1,1,3,5,1,3,2,4,3,5,4,1,1,5,3,4,2,3,1,1,4,2,1,2,2,1,1,4,3,1,1,3,5,2,1,3,2,1,1,1,2,1,1,5,1,1,2,5,1,1,4
__data
