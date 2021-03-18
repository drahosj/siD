module sid.mem.alloc;

import core.stdc.stdlib;
import std.stdio;

T * allocate(T)() {
    void *ptr = malloc(T.sizeof);

    if (!ptr) assert(0, "Malloc failed!");

    return cast(T *) ptr;
}

T[] allocArray(T)(size_t count) {
    assert(count != 0);
    void *ptr = malloc(T.sizeof * count);

    if (!ptr) assert(0, "Malloc failed!");

    return (cast(T *) ptr)[0..count];
}

void deallocate(void * ptr) {
    free(ptr);
}

void deallocate(T)(T[] arr) {
    writeln("Arr ptr ", arr.ptr);
    free(arr.ptr);
}
