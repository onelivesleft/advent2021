#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: true;
verbose :: false;


main :: () {
    print("A = %\n", test(dummy_a));
    print("B = %\n", test(dummy_b));
    print("C = %\n", test(dummy_c));

    #if confirm_test {
        print("\nDay 12 = %\n", test(input));
    }
}


Room :: struct {
    name : string = --- ;
    is_large : bool = ---;
    connections : [..] *Room;
}


room_find :: (rooms: [] Room, name: string) -> *Room {
    for * rooms  if it.name == name  return it;
    return null;
}

room_find :: (rooms: [] *Room, room: *Room) -> *Room {
    for rooms  if it == room  return it;
    return null;
}


Path :: [..] *Room;

empty_path : Path;

copy_path :: (path: Path) -> Path {
    result : Path;
    for room: path  array_add(*result, room);
    return result;
}


test :: (data: string) -> int {
    rooms : [..] Room;
    paths : [..] Path;

    add_if_not_present :: (name: string) #expand {
        room := room_find(`rooms, name);
        if !room {
            room = array_add(*`rooms);
            room.name = name;
            room.is_large = is_upper(name[0]);
        }
    }

    for line: line_split(data) {
        a, b := split_into_two(line, #char "-");
        add_if_not_present(a);
        add_if_not_present(b);
    }

    for line: line_split(data) {
        a, b := split_into_two(line, #char "-");
        room_a := room_find(rooms, a);
        room_b := room_find(rooms, b);
        if !room_find(room_a.connections, room_b)  array_add(*room_a.connections, room_b);
        if !room_find(room_b.connections, room_a)  array_add(*room_b.connections, room_a);
        assert(room_a.connections.count > 0);
        assert(room_b.connections.count > 0);
    }

    start_room := room_find(rooms, "start"); @Becomes_Invalid
    assert(start_room != null);

    walk :: (room: *Room, path_so_far: Path, results: *[..] Path) {
        array_add(*path_so_far, room);
        if room.name == "end" {
            array_add(results, path_so_far);
            return;
        }

        for neighbour: room.connections
            if neighbour.is_large || !room_find(path_so_far, neighbour)
                walk(neighbour, copy_path(path_so_far), results);
    }

    walk(start_room, empty_path, *paths);

    #if verbose {
        for path: paths {
            for room: path
                print("%,", room.name);
            print("\n");
        }
    }

    return paths.count;
}


dummy_a :: #string __data
start-A
start-b
A-c
A-b
b-d
A-end
b-end
__data


dummy_b :: #string __data
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
__data


dummy_c :: #string __data
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
__data


input :: #string __data
hl-WP
vl-fo
vl-WW
WP-start
vl-QW
fo-wy
WW-dz
dz-hl
fo-end
VH-fo
ps-vl
FN-dz
WP-ps
ps-start
WW-hl
end-QW
start-vl
WP-fo
end-FN
hl-QW
WP-dz
QW-fo
QW-dz
ps-dz
__data
