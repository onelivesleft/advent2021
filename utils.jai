#import "Basic";
jai_string :: #import "String";

parse_int :: (int_string: string) -> int, bool {
    s := copy_string(int_string);
    i, ok := jai_string.parse_int(*s);
    return i, ok;
}
