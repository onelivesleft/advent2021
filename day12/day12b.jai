#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: true;


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


room_count :: (rooms: [] *Room, name: string) -> int {
    total := 0;
    for rooms  if it.name == name  total += 1;
    return total;
}


Path :: [..] *Room;

empty_path : Path;

copy_path :: (path: Path) -> Path {
    result : Path;
    for room: path  array_add(*result, room);
    return result;
}

dump :: (path: Path) {
    for room: path
        print("%,", room.name);
    print("\n");
}

string_from_path :: (path: Path) -> string {
    builder : String_Builder;
    append(*builder, path[0].name);
    for 1 .. path.count - 1  print_to_builder(*builder, ",%", path[it].name);
    return builder_to_string(*builder);
}

test :: (data: string) -> int {
    input_rooms : [..] Room;
    small_rooms : [..] *Room;
    results : [..] string;

    add_if_not_present :: (name: string) #expand {
        room := room_find(`input_rooms, name);
        if !room {
            room = array_add(*`input_rooms);
            room.name = name;
            room.is_large = is_upper(name[0]);
        }
    }

    for line: line_split(data) {
        a, b := split_into_two(line, #char "-");
        add_if_not_present(a);
        add_if_not_present(b);
    }

    for * room: input_rooms
        if !room.is_large && room.name != "start" && room.name != "end"
            array_add(*small_rooms, room);


    add_paths :: (data: string, results: *[..] string, input_rooms: [..] Room, additional_small_room: *Room) {
        rooms : [..] Room;

        for input_rooms  array_add(*rooms, it);

        if additional_small_room {
            room := array_add(*rooms);
            room.name = additional_small_room.name;
            room.is_large = false;
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

        duplicate_small_room : *Room = null;
        if additional_small_room {
            duplicate_small_room = *rooms[rooms.count - 1];
            original_small_room := room_find(rooms, additional_small_room.name);
            assert(duplicate_small_room.name == original_small_room.name);
            assert(duplicate_small_room != original_small_room);
            for connection: original_small_room.connections {
                array_add(*duplicate_small_room.connections, connection);
                array_add(*connection.connections, duplicate_small_room);
            }
        }


        start_room := room_find(rooms, "start");
        assert(start_room != null);

        walk :: (room: *Room, path_so_far: Path, results: *[..] string, requires_room: *Room) {
            array_add(*path_so_far, room);
            if room.name == "end" {
                if !requires_room || room_count(path_so_far, requires_room.name) == 2 {
                    string_path := string_from_path(path_so_far);
                    if !array_find(<<results, string_path)
                        array_add(results, string_path);
                }
                return;
            }

            for neighbour: room.connections
                if neighbour.is_large || !room_find(path_so_far, neighbour)
                    walk(neighbour, copy_path(path_so_far), results, requires_room);
        }

        walk(start_room, empty_path, results, duplicate_small_room);
    }

    add_paths(data, *results, input_rooms, null);
    for small_room: small_rooms
        add_paths(data, *results, input_rooms, small_room);

    return results.count;
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
