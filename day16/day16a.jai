#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: x;  // x / _


bits : [..] bool;
view : [] bool;

version_total := 0;


main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    for line: line_split(data)
        parse(line);
}


parse :: (line: string) {
    array_reset(*bits);

    for split(line) {
        i := it - #char "0";
        if i >= 10  i -= (#char "A" - #char "0" - 10) ;

        array_add(*bits, i >= 8);
        array_add(*bits, (i % 8) >= 4);
        array_add(*bits, (i % 4) >= 2);
        array_add(*bits, i % 2 >= 1);
    }

    view = bits;

    bite :: (count: int) -> int {
        assert(view.count >= count);
        result := 0;
        for 1 .. count {
            result *= 2;
            if view[0]  result += 1;
            view.data +=1; view.count -= 1;
        }
        return result;
    }

    bite_packet :: () {
        version := bite(3);
        version_total += version;

        type_id := bite(3);
        if type_id == {
            case 4; // literal
            repeat := bite(1);
            value := bite(4);
            while view.count >= 4 && repeat {
                repeat = bite(1);
                value <<= 4;
                value += bite(4);
            }

            case;
            length_type_id := bite(1);
            if length_type_id == {
                case 0;
                length := bite(15);
                desired_count := view.count - length;
                while view.count > desired_count
                    bite_packet();

                case 1;
                packet_count := bite(11);
                for 1 .. packet_count
                    bite_packet();
            }
        }
    }

    version_total = 0;
    bite_packet();
    print("\n%:\n %\n", line, version_total);
}

dummy :: #string __data
D2FE28
38006F45291200
EE00D40C823060
8A004A801A8002F478
620080001611562C8802118E34
C0015000016115A2E0802F182340
A0016C880162017C3686B18A3D4780
__data

input :: #string __data
60552F100693298A9EF0039D24B129BA56D67282E600A4B5857002439CE580E5E5AEF67803600D2E294B2FCE8AC489BAEF37FEACB31A678548034EA0086253B183F4F6BDDE864B13CBCFBC4C10066508E3F4B4B9965300470026E92DC2960691F7F3AB32CBE834C01A9B7A933E9D241003A520DF316647002E57C1331DFCE16A249802DA009CAD2117993CD2A253B33C8BA00277180390F60E45D30062354598AA4008641A8710FCC01492FB75004850EE5210ACEF68DE2A327B12500327D848028ED0046661A209986896041802DA0098002131621842300043E3C4168B12BCB6835C00B6033F480C493003C40080029F1400B70039808AC30024C009500208064C601674804E870025003AA400BED8024900066272D7A7F56A8FB0044B272B7C0E6F2392E3460094FAA5002512957B98717004A4779DAECC7E9188AB008B93B7B86CB5E47B2B48D7CAD3328FB76B40465243C8018F49CA561C979C182723D769642200412756271FC80460A00CC0401D8211A2270803D10A1645B947B3004A4BA55801494BC330A5BB6E28CCE60BE6012CB2A4A854A13CD34880572523898C7EDE1A9FA7EED53F1F38CD418080461B00440010A845152360803F0FA38C7798413005E4FB102D004E6492649CC017F004A448A44826AB9BFAB5E0AA8053306B0CE4D324BB2149ADDA2904028600021909E0AC7F0004221FC36826200FC3C8EB10940109DED1960CCE9A1008C731CB4FD0B8BD004872BC8C3A432BC8C3A4240231CF1C78028200F41485F100001098EB1F234900505224328612AF33A97367EA00CC4585F315073004E4C2B003530004363847889E200C45985F140C010A005565FD3F06C249F9E3BC8280804B234CA3C962E1F1C64ADED77D10C3002669A0C0109FB47D9EC58BC01391873141197DCBCEA401E2CE80D0052331E95F373798F4AF9B998802D3B64C9AB6617080
__data
