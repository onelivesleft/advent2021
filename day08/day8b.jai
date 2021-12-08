#import "Basic";
#import "Strings";
#load "../utils.jai";

confirm_test :: x;  // x / _

patterns : [10] int;
fives : [..] int;
sixes : [..] int;


main :: () {
    #if confirm_test  data :: input;
    else              data :: dummy;

    pattern_from_string :: (s: string) -> int {
        pattern : int;
        for c: 0 .. s.count - 1 {
            index : int = s[c] - #char "a";
            assert(index >= 0 && index <= 9, "Index is %\n", index);
            pattern |= 1 << index;
        }
        return pattern;
    }

    output_total := 0;

    for line: line_split(data) {
        patterns_string, output_string := split_into_two(line, " | ");

        array_reset(*fives);
        array_reset(*sixes);

        for split(patterns_string, #char " ") {
            pattern := pattern_from_string(it);
            if it.count == {
                case 2;  patterns[1] = pattern;
                case 3;  patterns[7] = pattern;
                case 4;  patterns[4] = pattern;
                case 7;  patterns[8] = pattern;
                case 5;  array_add(*fives, pattern); // is 2,3,5
                case 6;  array_add(*sixes, pattern); // is 0,6,9
            }
        }

        assert(bitcount(patterns[1]) == 2);
        assert(bitcount(patterns[4]) == 4);
        assert(bitcount(patterns[7]) == 3);
        assert(bitcount(patterns[8]) == 7);
        assert(fives.count == 3);
        for fives  assert(bitcount(it) == 5);
        assert(sixes.count == 3);
        for sixes  assert(bitcount(it) == 6);

                a := 0;
        b := 0;         c := 0;
                d := 0;
        e := 0;         f := 0;
                g := 0;

        a = sub(patterns[7], patterns[1], 1);

        six := sub(patterns[8], patterns[7], 4);
        patterns[6] = six | a;

        {
            is_two_and_five :: (a: int, b: int) -> bool {
                diff := fives[a] & ~fives[b];
                return bitcount(diff) == 2;
            }

            if !is_two_and_five(1, 2) {
                if is_two_and_five(0, 2)
                    Swap(*fives[0], *fives[1]);
                else
                    Swap(*fives[0], *fives[2]);
            }
            patterns[3] = fives[0];

            diff := fives[1] & ~patterns[4];
            if bitcount(diff) == 2 {
                patterns[5] = fives[1];
                patterns[2] = fives[2];
            }
            else {
                patterns[5] = fives[2];
                patterns[2] = fives[1];
            }
        }

        b = sub(patterns[5], patterns[3], 1);
        c = sub(patterns[3], patterns[5], 1);
        e = sub(patterns[2], patterns[3], 1);
        f = sub(patterns[3], patterns[2], 1);

        for pattern: sixes {
            if      pattern & c == 0  patterns[6] = pattern;
            else if pattern & e == 0  patterns[9] = pattern;
            else                      patterns[0] = pattern;
        }

        d = sub(patterns[8], patterns[0], 1);
        g = sub(patterns[9], patterns[4], 2);
        g = sub(g, a, 1);

        test :: (digit: int, count: int, location := #caller_location) #expand {
            result := bitcount(patterns[digit]);
            assert(result == count, "\n\nLine: %\nDigit: %\nExpected: %\nGot: %\n", it_index + 1, digit, count, result, loc=location);
        }

        test(0, 6);
        test(1, 2);
        test(2, 5);
        test(3, 5);
        test(5, 5);
        test(4, 4);
        test(6, 6);
        test(7, 3);
        test(8, 7);
        test(9, 6);

        digit_from_pattern :: (pattern: int) -> int {
            for 0 .. 9  if patterns[it] == pattern  return it;
            assert(false, "Couldn't find pattern");
            return -1; // unreachable
        }

        output := 0;
        for digit_string: split(output_string, #char " ") {
            output *= 10;
            output += digit_from_pattern(pattern_from_string(digit_string));
        }
        output_total += output;
    }

    print("%\n", output_total );
}


format_bits :: (i: int) -> string {
    builder : String_Builder;
    init_string_builder(*builder);
    append(*builder, ifx i & (1 << 9) then "1" else "0");
    append(*builder, ifx i & (1 << 8) then "1" else "0");
    append(*builder, ifx i & (1 << 7) then "1" else "0");
    append(*builder, ifx i & (1 << 6) then "1" else "0");
    append(*builder, ifx i & (1 << 5) then "1" else "0");
    append(*builder, ifx i & (1 << 4) then "1" else "0");
    append(*builder, ifx i & (1 << 3) then "1" else "0");
    append(*builder, ifx i & (1 << 2) then "1" else "0");
    append(*builder, ifx i & (1 << 1) then "1" else "0");
    append(*builder, ifx i & (1 << 0) then "1" else "0");
    return builder_to_string(*builder);
}



sub :: (a: int, b: int, expected: int, location := #caller_location) -> int #expand {
    result := a & ~b;
    assert(bitcount(result) == expected, "\n\nLine: %\nExpected: %\nGot: %\na:   %\nb:   %\n",
           `it_index + 1, expected, format_bits(result), format_bits(a), format_bits(b), loc=location);
    return result;
}


bitcount :: (i: int) -> int {
    #asm {
        mov i_gpr:, i;
        popcnt i_gpr, i_gpr;
        mov i, i_gpr;
    }
    return i;
}


dummy :: #string __data
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
__data


input :: #string __data
gfeabcd adecfb gcedb cef efgdc decabg cbfg edfga fdegcb cf | fc faedg fdage fec
bcfegd fdceg ecgfadb fdae af cdeagf afc abdgc gcadf gfbace | cefdbg afgedc bcagd gedcf
gbf bagdec fgdbae cfbd bgacd fb fbcaegd dfgbac gbfca gecaf | gadcfb abgcf bdcgea gbf
eagcf cdgbaf cbadg fbcdgea cebfad fb fdgb abf gcdbea cgabf | bfdg dgacb gacef bafcg
bgface cfadb gfc gcfba febg aedcgfb bceag cdgaeb adfecg gf | acfdb fabdc efagdc facbd
bfegac adbfg ebagf beafgcd gfeadc age cgedbf gfceb eabc ae | acbe gfcbea aefgb abdgf
bfeag cbae cbg bc cbaefg cfdga fgdbec ebadgf eacgfdb gabcf | bfgcea eabc eagfb bc
abdcfg aebfd fbcade cdbge cfae eafcgbd dcabe bca degfba ca | ecfa fcadegb edbfag abc
dfcgea efcbg ecda fadgbc fac bdacegf ac feabgd afgde ceagf | fdgae abgdfc egcfa fagde
gfd gdcab fgdcae ecdfb bfdgc dacbef fbeg fg fdcgbe cdagbfe | bacgd cfdbea efacdg bcaefd
eb afbgd gafbe bef gacdfb gdecfab aecfg egdb defgab bdaefc | gacfbd bfaecd gabfdc bef
ecfb cbdfeg fgbadec fgcdb egf cefdg eagdc fbcdag fe gadbfe | fbgade bedfag gafbdc ecfdg
bafcdg gbd dbcgef ecgdf cbged cgabe faebgcd cgfeda db debf | bdg efdgc fbed gbcde
gdfceab afced decafb gadfc fg agdbc befcga fegd cgf cfegad | egdf ecafbg gbcda dcagf
eca ea efda cfbda badgcf dbcea edcfab abfcdeg bagfce cbdeg | efad fedcba fgcbea adfbce
gdefbca cf acbfg cegbda begca fbc gfebac afce gbdfa bdfgec | cbf bfc gecbaf cbafg
afcebd agebfc fbcea eadfbg bdf cdfa dfecb df cbdfgea becgd | ceagbf fcda becfd ebfac
ecb adgfeb fedbgca efac cfdegb egbaf ec bgcda gefbca cgaeb | afbdgce bec ec feca
eacdb dfcabe dg fdabgc cdg gaed cbaged gecdb ebgcf dagefbc | debgc dgaceb gcd fdebca
cega gdbefac gfdcb efbgca ga afg cgbaf aecfb ceabdf edgbaf | fedagb dbafce ga ga
efbadc acgde fagcde fe dcaebg edfg acgef cbagf fae acfebgd | ef badcef dfge gecfa
cbgfa cbae dabgef ba bag fcgea fdcage gfbcd cgbdaef gfecab | aefbgd bfgac gebacf bgfac
dgfbce fgc bfcda egdfa gc fgedab acgdf acedgf aegc fbcgade | dfagc bgdafe aegfd egfda
dgfa bedfc badcf agfbcd af eadbcg bfegca bfa cgabdef bgadc | bgdacf dcfba fcbda gbedafc
aceg gdaef fcbegda dcefab afcedg abgdfc cadef agf degbf ag | bdgfe bacfgd cadfe fcgeabd
bgefcd edg acdegb edcba cbdefa cfaeg beacgfd egcda dg dbga | efagc abcdegf adfceb dg
faedbc gabde becfgd caebf acfg eacbg cgabfe cdebfga gc gcb | cdgebf cefab abdfce gdcefb
de cgdfb edbg dbacfge cdfeg cebdgf agcef afbcgd dce dbfcea | beadfgc gbcadf dgcef degb
egcafb cgadfbe gdace fd bafce cedabf bgdefa dcfb afd ecafd | gaefbd dfcb aebcf gcabfe
cb beafcd bdgacf cdb bgac edgbfac cgfed bcgfd bgfdae gdabf | bafdg gcba fbgcd cegdf
fceba ag degafbc bfcga bcafeg agf bafedc gace bfdcg fedbga | bdefca fcgbd cbafe cgbdf
cafbge ce fbcea fecgdab aec adbcgf fbgca bgec baedf fegdca | defab bcfae ecgb aec
dgbc dagfcb acfgbde bad adcfg dabfc gacdef aebdgf cabef bd | acfdb defgca dbegfac gfdca
ecdf degfb adbge fcbgea dbgfec gfd df egfcb gacdebf cdfgba | cgbdfe gfd cfegab gfabce
defcbga fcade efbac fb gacdbe abceg abcdgf egbf fcbgae bfa | befg cabdge eafcb bf
cfbdae cg decbfag egfab fgdc dcbfe fegbc gce gdebca bfdgec | dcfg eadgcb ebdfc gfdcbe
eagcdf cfaeg dgfe bdcefa gcabfed cgbda cegfab dae cagde de | dae adbecf edfcga fdge
egfa gfbeac cfbag af fcgbe egbdfc abf cgbda ebfadc gbaedfc | cagefb edcbgf gebfc egcfb
gda ga bcadge gfea dcbgef adcfb fdebg cgbfdae gfdaeb fabdg | fegbd egaf dafgeb gda
gefad fegbad adecbfg db bed eacgb fcdgeb agdbe adbf acgfde | fabedcg bed gfadeb gedafc
fb cbefa baf dfbgca edfac gefbac eadbgc efbg gfecbad aecgb | dbacfeg degabc fgacbed febg
cbgfad eabcfgd cfdeg fbd adegb fb cfeb egbcfd fbegd agdefc | fdaegc febc fb ebgad
dbfgc badc cfdabg fgaceb degfab facegdb dgb efgcd fcagb db | gfbca cgfbd gacfbed fbgdc
efgcbd efbdc ef febdag dagfbc fcge bfdcg dabcefg edf ecdba | cbdegf defabg dcgabf bcade
ecdfbga cbdeaf bfgdc fca eagdfc eafdb bdfca ca caeb gfeadb | cbae dcbfa acf fgcbd
gdefcba bafd efcdab gecdbf fdc becfa gceda fd cafde baecgf | dfaec cabedf abcfeg df
cfb daefb bgfcde dgacb edfcagb acfe fdbcea dcafb cf febagd | fecdba dfcageb fabcd ceaf
adgbec fcgb badgecf dagcb bagefd fdb bf dcbfa bfadgc cfdea | fb efdac cfdba gadcb
afcgd bac gdebfca bcgaed afbcd ecdfgb dcfbe ba befa eafdbc | dcgfa dgbfce ab afcbed
gbcdaf fdgac bagde cgdbaef eabgcf bf gecdfa gbafd cdfb fgb | aecgdf bdega gafebcd aefgbc
gfeb cadfg bdfga aefgdb bgd bagdcfe bgeacd gb cebdfa efbda | dafebc bfadge dgb adcfg
cda dageb fgebda bfcdage dcbeag cgade cefbad ca cbga cfdge | gbadec febcad beadg cfbdea
gdabf eadgf fe defagcb abef feg gabcdf cedag dafgbe edgcbf | abgfde gedafcb cgeda adgec
fbd gfeba fgecad edafgbc dfcbga abdgf cadfg cgdb bd aecfbd | agfcbd ebacfd bafdg dagcf
cadefb cgde eg aebfcg fdbagce afdceg fbagd aeg dfage aedfc | gdaef fedca eg ecabdf
dgbeaf fcbdga ae agfcd egabdcf deac dcgfae acgfe fbceg gea | aecd dace gcbfe gcfea
dafeg fcg degbac gcdbe dcgef bdegcf gedbcfa cf ebfacg bcfd | agfebdc cegdf cf cf
bdfcea bdgae ecbga dbg fegbda bdefa dg dbacgf geafbdc efgd | bdg gefd cagbe debga
aegfdb afcbd cdaebfg dgafbc cagb ba dcefb fba cdagf fgadec | fedcb acbg bfcdga gfcaed
bfagcd agfb afcdg fcegadb dfgecb gb adbec gabdc efacgd gbd | eacbd adcfg fbgadc dbgca
fcedg dfgbea ea fcbadeg ade agefdc afcdb egca ceadf fegcdb | dfgce efcgdb dgecbf cfabd
dfea ed agdfebc eabfc bcdgfe edc cdbga ecbda aefdbc acfgeb | bdaec abfec gbedcf acbde
dgefcb fbcaeg fbcga bgfcaed bfgda dcbfag fgd cfda edbga fd | bgcfae abgdf acfgbe abegd
dgabfc cgdfe afd fdcae af agfe decba fcebdg dgfcbea dgfcae | fcaed fcabdg eafg fa
gafce debca gdfeca dfag dacbfeg fcbedg ceagbf fdc fd cadef | ecfad gcbefa begacf edbcgf
daceg efdcbg fcgad dbeca bdface bcfagde abge ged aecgdb ge | ecgdbf egcad eg aebg
fdbace debagc cgbef degba bacfedg gfda afb edfgba gbefa fa | fbdgcea befacd cdaebg fbaegd
fgbdea dg gdfb gfcebad abfeg afecgb dagbe edcgfa cdeba edg | egd fbgd dge eacdb
ge agdcfb fdcag fcbgaed degcf eadg bdcef acefdg bcfaeg gfe | aecfdg eg dcgfa caegbf
bcgef gfdb bgfcae fcadbge cedbg edafcg dg dcebgf bacde dge | agefbc bgefcd bedfcg dg
fga ga dcgfb dgeabf beadfgc eadfc gbca dcagf fadcbg bcgfed | ga dgcfba agcdf befcdg
dbag cafgbe cdfgaeb gabcde eabdc fdace bd bgcea gdecbf bcd | afdec abegfc gebacf edgabc
fcde cbadefg gdcefb bcdagf bcgef fdg abgcef edbfg df eabgd | egabd dbega gfcadb dbega
bfdag adbefc efdgcb fceab dbc cfdba egafbc dc ceda beacdfg | dbfcge cd fbcea efacb
dgaeb cgbeadf afbeg gdbfae ebadcg gdfb acgedf fg abefc gaf | fcdgbae gf bgaed fbaedg
cfdbeg dcfaeb cagbe cfgabde afdc fbaed cfe bfaec bgadef fc | fcaedb gbeac cfdgbe afdc
ceg dgecfa abecfg agcdfbe gcdae gfdcab fdec gbead ce acfdg | cgfad fgebca adbfgc dagcf
dcf cgebfa dc gdcaef eacgbdf cdefgb cebd dagfb cdgbf cfgeb | cd bgadf dbfga dgfba
gebac caefd bf bgacedf ebfdgc dbaf cfb bfeca agcedf dbcfae | debgcf adcefb befgdc gaecfd
abec bafgc fcebg fbaceg dcefgba degfb gec acdfeg ec fgdbca | dbgfe gdbfe ecgbf bcea
egafbd egdbc bdc cbfdag fcde ecbdfg fgbde ebcag debgafc dc | cdbeg fabedgc fgdecba dc
ecdgfa ag badcegf gaecb eabgfc adecbf cag acebf fbag dbceg | ebgac bfag dgacef edgacf
afgeb adgcbe efdb fgeacbd ceagf gbdefa eb bea dacfbg dabgf | eab bgfdea abfge bdfcage
egbdac aefdb fgdeb dabfc ea dae dbacfeg cagbdf caef eabdfc | cadbf ae dafcgb beadf
egcadbf gbce debac dge adfebc ecgad gdcfa dgcbea gdafeb eg | dgbfae ge adcegb bdfega
fecag dc fgecd dgcb edc fbedca dbcfeg gbedaf gfdbcae ebgfd | dce gbdc edgbfc fedcba
cafebdg adcfge debfac dgcae gec fbdegc ge cgdab faeg ceafd | gafe bagcd edfac cbagfde
dc bgcaf gdcebaf ecgdab cagdf efabcg dgc dcfb fgeda cgbafd | gbcfea dacebg bgfdcea dc
afedc ebfcg dgfbac adbe eafbdcg fdbce bd fbd bdafec afcdge | baed cfgade becdf dbcfea
bdae fbdac deafcb badcegf bcefga badfgc efcgd eb dcebf ecb | bcafdeg eagfcb dcbfag fcdbga
gb dafbce feagd bdegf bdcgafe fdgebc acdgbf cfbde ebcg bgd | adgfcb cgeb bceg dgbcfe
cbdfge bdceag fc edbgc dgfae bcdf fce bcefdga dgefc ebgafc | cdfge bgecaf fdgce cf
ba fcgae gecbfd cefbd cba afdbce aecfb beda fagdcb facdbge | ebad ecagf ba deab
ba baf ebacgf fcgad fbcdeg bgcef gadbecf ecfadb acbgf geab | cgdbfe ba dbceaf adbecf
cdfga efd efagcb egbd ed gacedfb fbdeca decgf gbcef gfbdce | cfedg bedcfg gecbf gbfce
fegbca ega egfdca gfeba afbec fadbg defacb gcbe eg dfagecb | ebacdf bdgeafc dfabg efabc
fdb efcbad bdaeg fbgade gfbe egacfdb adfgc bf dcebag badfg | dfcga bfd adfcg dgbaf
ead agbcd de bcgeda gedb agced cdafgeb bfcgda adefcb fecag | cbgead acdgb edacbf dfeabc
cagdfe egfca geacd dg gbaecf ged agfd cebda edcbgf decafbg | gbaefc ecgaf cgbaef gcfdbe
fd agcfedb adgfb cdaf degab bfacg cebgfa bdgfec fbd dcgbaf | abdgcef dgacbf cfda cedfgba
cafbd fgcb bgcad gdfcba eadbf adecgb cfa efgadc agcdefb cf | fc fdbcag fgeadc fegdca
dgcf eadcg fg dabfe gdefa efg cegabd fadecg gadfbce facbeg | aecbgd gceda gdecab abcgfe
ebfdca agbdcf gfadc bfc afgb cdgaef egcdb gbedfac fb dgbfc | ecbfadg baefdc bf dbgec
fabcge cafged beg abfdge aegdf dabg fgbacde bg fdebg bcfed | efgda dgefba gaefbd bagd
gbfda afbcgd acefdg adb bd gbfae dfcga acegdb acfdegb cbdf | dbfc abd bd dcabfg
ecgdf abcedf gfcdba eadb ecb fdcab fecbagd be eacgbf ebfdc | gdbcfa ecfdab deba efbagc
ca fcda efbdgc ebgda bgefacd cea cdebf bdefca efagbc ebcda | fgebca egabd edcbaf acfd
agebd dcge ed gaebc fegacb cfaebgd bcedfa gfbad dbe cdgeab | dbega fbeacd gaebcd gfcabe
bg edfagb daecgf bgafdce bdeag cgbdaf ebgf ebdac bga edfag | dabcgf cbaed ecdba abg
efdcg afbd bfdeg bgf fgdaecb dagceb fb gcbafe abgdef egbad | fbeagd bcdafge gdbfe fgdbe
becfa fg dgfe dfaegcb cedfbg begdca fgceb facbdg bfg gebcd | fg gebdcf dcbega cdegb
edgacb cb cefdba gcaefd adcbg cdb cbge efgdcab gdeca fadbg | gcabfed cb acgdbe gbafd
cfgbde eagdbc cegdb ebcf bdf fb fbgde facedgb eafdg dcbgfa | cdfagb cfbgde bf dfegcb
gedcfab ebfcda ecdbf gfced fcebdg gcd gdeaf cg cdbgae fgcb | cedafb gdfecb cg gc
fbe edbfca feadbgc cbefga fb dfaeb abdge eacdf gfedac fbdc | fadeb acbedf fbdae daecf
dgacbef efgba dgbfe fecabd bgaefd bde dfcbg de aedg bfgeca | bdfcg ebfdac eagfb gdae
efbgcd aedgcf acd cafbd gbfdaec bagc bcfgd ca gdafcb dbfae | bcadgf beadf ca fgcadb
edgfba fbged aed gadcb bdgae ea efga cdbefa cbefdg dcabgfe | dfbcae bfceda ae gbaed
gdc dfgbeac adcf bfecg abgfd bcdfg dabfgc cd fbgdae dbeacg | gcbfd fdgba afgdcb gbdcae
ca acd ecfbdg fcdeb cdfbea gcabfde afdce cbaf afedg cgadeb | cdbef ca dbecf agfed
gfceab ed fgecd fdgaec gdbfc eacfg cdegfba dcae deabgf efd | eagdfb ed cefag aced
baced dg deabfg dga adcge gcfd acgefd acegf acbdfge fabgce | egfdac becad aebcfgd gcdae
ed dec cdabgf acefb ecbfdga becagd gdbac cedbgf adeg edcab | bdagc acebd bdfgac gdfbcae
gefbca edbfc agdf bgadce fegadc ceagf gafdbce ecfgd dg gcd | gdfaec bfecagd gacefb acgbefd
cdega fcdbga gbfceda gafbde adgcb egfcd ceba dea badecg ae | aebgdc dfbage badfge edgcf
egcdfba ebcga gfe adgcef gdbf bedgaf gabfe dbefa fg cbdfea | gdfaec dfbg abedf gcdfae
feabc gdfeab ebgdafc fa cebga cadgeb gafc fbgeac ebcfd fea | gcabe cbgea febadg fcag
afdb agdfe bdcafge fdaegb aegbd gefdc abdecg aecfbg afe af | fae adfgbe af degab
fdg cdafgb fg cdbef bgfde gfea edbag ebadgc bgaefd adfcegb | befgd dfbgca baedcg gedba
aedgfc afegbcd ag bcedga bedafc aedbc agd gbcda baeg gfcdb | edabc gaeb afedgbc agfdce
eafdc db fcgbe dbac dcbfaeg ecfbad bdf bfced beafgd aedcfg | cdba bd cbafed db
cf fcebgad adfeb afdbce afgcde debgc cbdfe cafb cfd dafgeb | bdecg aegdfc cf dbcegfa
dfceab cebgad fgcbade dae ecdgb bgae dagec fdbgce ea dcagf | eagb ceabdf dcfeab badgce
dgf agcfed gacf afcde dgcef dgaefb efdacb egbdc fg bdeafgc | acdef afgc gdeafcb fdegab
abc aegfcb bc aedgbcf abdce eagdc gdceaf bdfae dcbg aedgbc | fbacge cadgbe gcaedf fdeba
ebdagf ac gcbfe agc aebgc gcbfeda cbdgfa edabg dcae acbdge | cbgfad cag dgfbca abfegd
cdafbge bgf afgd adcebg acefb gf dbgca agdcbf gacfb cfdgeb | dagf dacgb cfabe dbgfce
ebgfacd eafgcd dbcafg ebcafd gdeac afeg eac bcgde afgcd ea | fdbgac dfgca ceafbd gfbacd
gfeb gcdbfea dbecg edacgf fbdac efcdb fbdgec acbedg efc fe | cedbg bcfad ef fec
gfbecad faegb gcdfea cfg gc bceg bagfc fagdeb bacdf fcabeg | aefgcb cfg dafbge agbfdce
bfcedg decba agcf abegfd bdceagf bgacfe cg cbgae efgab ceg | fbceag eabgfc gc abgfec
adebcf agbef abegdc bedgf cfbadeg bedcf fgcd gd bcdfeg gdb | cbafgde dbefc gdb abefg
aeg cdabeg cgfadb aebgd ge ecafgdb edbfa acgdb gafedc gecb | cbge agefdbc cgdafb fdabe
febag ceba ceagf dabfge gce cabedfg cadfg efbcga ec fbdceg | edgcbf bgefa fecag afcgd
faecdb cea dabfgc dfagceb baed dgfcae caebf ebgcf ae bdacf | ae fbaecd ebcgf bcfda
gefc efbdga ec bdgfe fcbeda ecadgbf cbgde cedgbf bce bcgda | ce bec ecdbg gcbad
dbaegcf dbgaf agbde dcebfa gfdc fcabg gcfbda df ceafbg dfb | becdfa dbf egafcb bfagd
gfdae gbfec egcdf afbceg bcdf acgdbfe dabcge cfegbd dc cde | fcdgeb dbagec cafbeg gacebd
fg edcgafb fcadb bdgae fgbda ebdfac fabcgd gecfdb gfd gafc | cefgadb fg cbfged gf
bdfea fceba fc agbce ecdgfab gcefad fec aebdgc bcegfa cfgb | dbfae efc ecbfga gdceaf
cdfgb gefcda abdgce beagd ec bcae dbgfeca ecg ebdgc abfedg | dgabe adgcfe fdcbg ec
fbedc egfabd gadcf dcfeg aecdbgf gcea eg dafgec fcdagb fge | bafedgc eacg ecdfg deafgb
faegdb fdb bgfdec bcgda agfebc gcebdaf cedf gdfcb cfbge fd | dbegacf cfaegb gfcaeb befgac
gbacdfe fdgcba befgc fabe bcf edcbg cgfeab cfaeg fb acdfeg | cfeag bcgde ebaf fgcdab
gef dceg edfbc baedcf bdagef eg cfegb bfacg afgbced decfbg | dfegba cfegdb eg gacfb
cba adgcfeb abfdce dgecbf ca ebdacg becdf adfc fbeac fabge | fbaeg gfbceda fceba bdaecf
cb adefc egcb abc bedgac ecdab bdfgca eabgcfd edagb dabfge | bfdega fagcbd abcde agdeb
dgfbae efgbacd gcdf bdg gd bcgdfe bgcde bedac cgbefa bcgfe | gbd aedcb ecfbg ecdbg
gcafedb ecdbfa fedcg dcefga dfgca gbcde gfae ef fec bdfcga | fdgcabe cbadef fcgda ebdgc
eca ea fbadec debcg agef edcga caedgbf fadgc dgafec cfbgda | cbdeg cedgbaf aecdfb dcgea
afc gbafec egbdfca ca eagbfd aecgf abfeg gcba abedfc dfgec | gafbe cedafb afbeg cagfe
agbde eabcgd fe dcfgb efd becdgfa dfageb fdebg fdcage bfea | def edgfb acfedg bgead
gbdec facbgd ag gba bgceda aedcbgf eagd cgabe bface fbdecg | eagbc gcbdfa bafcgde eacbf
dbacfge cagfdb geba cefgda bgc eacgf caebfg cbdef bg fcbge | bg abcegf efgca cfdeb
gaefc cgefdab fdcaeg aegfdb gb badfc gbf bcfag gbfeac gceb | bdafc aefgdb gfcae dfcab
dbceg bcafgd cfabde cfabdge aed ae deacb face egfbda bfdac | cgabdf fgeadb ade dcbge
dfbgcea fbeca cefbg dfgc bgaefd dbecga gfe fg efdgcb cdbge | gcbfed cfbeg gdfecba gecbd
gaced bd edfcag aecdfgb bgad edcbg debfca deagbc bdc egfbc | bdc cdb efcbad dagb
egfca bgea adebfc gfceab cfebg cdefag dgfbc bgadecf ceb eb | dcefag facgeb edbfca eacfg
fged bcaeg fcgbde gdfacb fcadbe bfcge ebfcd fcg edabgcf gf | gfbdac efcdb gfceb fgdceb
fgbdeac facdb agcf fc bfegcd bedfa gbcda bcdfga fcb degacb | bgecad cf dcgbfea gfca
dafbgc cfdga dgafeb db cfdage bcfaedg fbgec bdf dcab cdbgf | cfdgb befadg ebgfc acdbfg
eadgf gdefab ebacd fc eafgcd caf deafc egcf dacbegf bfdagc | egadcfb agfdcb debca fdcagb
dgaecb efd gbecdf fgdcae geaf faecd dfcab bcfagde egcda ef | fe ecagd efd fed
dbaf bf bfg ebfcga degba cedfg adfcgeb edgfb begafd daecbg | cbegda cbeadg fbg cgfde
gdebcfa cbfad ecgfd fbeg dgfbc bg gfcade gdb gdbecf gdbeac | fdcgbe begf acgedb cbdfg
acfdge cadgbf gecfd dbefc fg agcebfd cfg gedac adcbge efag | egaf cbdgeaf gfc bdfgca
fbgad eabg bcdafg bde edcfab fdgec degbfca badgfe dbgfe be | egbdf bgadf bfdge edgfc
gfceab acf ceafbd cagdbe bdaf dcfae af febacgd fgdec daebc | cegfd dacfbe faebcd adfecb
bgefcda facgb bcg fgec cgebad gc efagcb bdgaf fecba dcfbea | bfeac acgfb ebcaf bgadf
eagbd abcgde afedc gcbe bac debcafg bgacdf bc dbcae gadbef | cba adcfbeg efdac cb
fbead gdebfa cabge adfbgce dcb dc aebdc dacfeb dcfa gbfecd | decfba cd dc edcgfb
gcbae ecfbag gebcf edabg efagcd cga ac beagcdf bcfgde fbac | fgecb gdabe agc ca
dfgacb fadbg afebdg acbgefd gdbc cgafd efgac cd beafcd fdc | daebfgc cebfad bgdeaf dcf
cfdeab efgadc cfbag ef cagbed dbcea ecfab cfe befd gecdfab | fgecdba cabde abefc dbcae
fadec cbgade acbfe df cdf acfdeg afdg gabcfed acged bfdcge | efcda ebfca ebgcfad dcage
cdfgeb eabgcdf faegc facgbd gdc efbdac fdbca fdgca gd badg | dfbceg cfdba cfgda bcadf
cdeafg ecfbgd cb eabc aegdcfb cdfba bfc cdfeba edfac dagbf | ceafdg feadc fbegdc beacdfg
acfbde agc cabgf cfdba gfecb bgadce bcgfda fadg cebdgfa ag | cbfad cebfagd agdcbf dcabf
dfeag fgbedca dfceg fcgaed egdcfb edbcga aefc gfadb aeg ae | gefda gabfd egacdf dfbgec
gfbec bdcaegf cdb bdacgf dgcbae gdcaf cfdage bd badf dbfcg | gaedbc dcb fcgdb afdbgc
cgdef geafc fd fdgbac degbc dgcefba cfeabg dfae cafdge dcf | egbcfa defa df dcf
cafed gdbfa cbfade cfgead cb gecbfd gdbcfea bcea cfb bacfd | bcea afdbg cbegdfa afdcbge
ac fcdgeba gdfec bdgefa fedab eac fadce aecbgf dbac aedcfb | efgabdc cafde bacefd cfeagb
begcf eagcdbf cfg bdcfea bfeca cfdagb bfged caeg cg acfegb | bgfde dgafceb dcfeab dgacfb
gbdfca fadbg fbc cb bdfgae abgcf feacg dfabceg dabc cfgdeb | cbf fcgdeb eafgc bdfgea
fcaegbd abgdce fdcgab gf bfgcae bfg gbfea abgce fgce ebadf | fdabgc gcfabe aebgdfc gbdcae
cdagbe gedbacf efbcad ebdag be gbcfad gbdac ebcg ebd egfda | efgda ecgb gbecda bdfgca
bfdgac gdecb abcde daefc efbgcd ecdbga agbe dab ab cfgabde | ebga ab cgbfad eacdb
efgda ac acf dfgbec dfeac edfbc ecfdgba fceabd bfdcga aecb | ecadfgb abcedf cefad cabe
__data
