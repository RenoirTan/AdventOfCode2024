U8 locks[500][5] = { 0 };
U8 keys[500][5] = { 0 };
U64 n_locks = 0;
U64 n_keys = 0;

U0 Main(I32 argc, U8 **argv) {
    if (argc < 2) {
        "No file included!\n";
        return;
    }

    U8 *contents = FileRead(argv[1]);
    U64 clen = StrLen(contents);
    for (U64 ci = 0; (ci + 42) <= clen; ci += 43) {
        Bool is_lock = (contents[ci] == '#');
        for (U64 x = 0; x < 5; x++) {
            for (U64 y = 0; y < 7; y++) {
                U8 c = contents[6*y+x];
                if (is_lock && c == '.') {
                    locks[n_locks] = y - 1;
                    break;
                } else if (!is_lock && c == '#') {
                    keys[n_keys] = 6 - y;
                    break;
                }
            }
        }
        n_locks += is_lock;
        n_keys += !is_lock;
    }

    U64 sum = 0;
    for (U64 l = 0; l < n_locks; l++) {
        for (U64 k = 0; k < n_keys; k++) {
            Bool ok = true;
            for (U64 i = 0; i < 5; i++) {
                if ((locks[l][i] + keys[k][i]) > 5) {
                    ok = false;
                    break;
                }
            }
            sum += ok;
        }
    }

    "%d\n", sum;
}