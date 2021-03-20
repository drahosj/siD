module sid.mem.refcount;

import sid.mem.alloc;

struct RefCountedArray(T) {
    int * refcount;
    T[] array;

    this(Args...)(ulong count, Args args) {
        array = allocArray!T(count, args);
        refcount = allocate!int();

        *refcount = 1;
    }

    ~this() {
        decRef();
    }

    this(this) {
        if (refcount !is null) *refcount += 1;
    }


    void opAssign(RefCountedArray!T src) {
        *src.refcount += 1;
        decRef();
        *refcount = *src.refcount;
        array = src.array;

    }

    void decRef() {
        if (refcount !is null) {
            if ((*refcount -= 1) == 0) {
                deallocate(refcount);
                deallocate(array.ptr);
            }
        }
    }
    /* Array compatibility operators */

    @property length() { return array.length; }
    @property size_t opDollar() { return array.length; }

    ref T opIndex(size_t i) { return array[i]; }

    T[] opIndex() { return array[]; };

};
