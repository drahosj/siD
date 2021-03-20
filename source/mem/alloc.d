module sid.mem.alloc;

import core.stdc.stdlib;
import core.lifetime;
import std.stdio;

T * allocate(T, A...)(A a) {
    T *ptr = cast(T *) malloc(T.sizeof);
    if (!ptr) assert(0, "Malloc failed!");

    emplace(ptr, a);


    return ptr;
}

T[] allocArray(T, A...)(size_t count, A args) {
    assert(count != 0);

    void * ptr = malloc(T.sizeof * count);

    if (!ptr) assert(0, "Malloc failed!");

    T[] ary = (cast(T*) ptr)[0..count];


    foreach(i; 0..count) {
        emplace(&ary[i], args);
    }


    return ary;
}

void deallocate(void * ptr) {
    free(ptr);
}

void deallocate(T)(T[] arr) {
    writeln("Arr ptr ", arr.ptr);
    free(arr.ptr);
}
