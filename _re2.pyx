from libcpp.memory cimport unique_ptr
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from cpython.string cimport PyString_GET_SIZE
from cython.operator cimport dereference as deref

# distutils: language=c++

# TODO: is there a better way to define it?
UNANCHORED = RE2.Anchor.REUNANCHORED
ANCHOR_START = RE2.Anchor.ANCHOR_START
ANCHOR_BOTH = RE2.Anchor.ANCHOR_BOTH

def _compile(str pattern):
    pass

def escape(str line):
    cdef _StringPiece sp = _StringPiece()
    sp.set(line, PyString_GET_SIZE(line))
    return _QuoteMeta(sp)

cdef class Set:
    cdef bool compiled
    cdef RE2.Anchor anchoring
    cdef unique_ptr[_Set] re2_set_ptr

    def __init__(self, int anch=UNANCHORED):
        self.compiled = False

        if anch == UNANCHORED or anch == ANCHOR_BOTH or anch == ANCHOR_START:
            self.anchoring = <RE2.Anchor>anch
        else:
            raise ValueError("anchoring must be one of re2.UNANCHORED, re2.ANCHOR_START, or re2.ANCHOR_BOTH")

        cdef RE2.Options options = Options()
        options.set_log_errors(False)
        self.re2_set_ptr.reset(new _Set(options, self.anchoring))

    def add(self, str pattern):
        if self.compiled:
            raise RuntimeError("Can't add() on an already compiled Set")

        cdef string add_error
        cdef _StringPiece sp = _StringPiece();
        sp.set(pattern, PyString_GET_SIZE(pattern))
        cdef int seq = self.re2_set_ptr.get().Add(sp, &add_error)
        if seq < 0:
            raise ValueError(add_error.c_str())
        return seq

    def compile(self):
        if self.compiled:
            return

        if not self.re2_set_ptr.get().Compile():
            raise MemoryError("Ran out of memory during regexp compile")
        self.compiled = True

    def match(self, str text):
        if not self.compiled:
            raise RuntimeError("Can't match() on an uncompiled Set")

        cdef vector[int] idxes
        cdef _StringPiece sp = _StringPiece();
        sp.set(text, PyString_GET_SIZE(text))
        cdef bool matched = self.re2_set_ptr.get().Match(sp, &idxes)
        return [i for i in idxes]
