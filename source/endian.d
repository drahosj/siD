module sid.endian;

uint be_to_uint(ubyte[] buf) {
	uint val =
		(buf[0] << 24)  |
		(buf[1] << 16)  |
		(buf[2] << 8)   |
		buf[3];
	return val;
}

ulong be_to_ulong(ubyte[] buf) {
    ulong[8] lbuf;
    foreach(i, b; buf) {
        lbuf[i] = b;
    }

	ulong val =
		(lbuf[0] << 56)  |
		(lbuf[1] << 48)  |
		(lbuf[2] << 40)  |
		(lbuf[3] << 32)  |
		(lbuf[4] << 24)  |
		(lbuf[5] << 16)  |
		(lbuf[6] << 8)   |
		lbuf[7];
    return val;
}
