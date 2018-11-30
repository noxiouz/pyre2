# distutils: language=c++
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector


cdef extern from "re2/re2.h" namespace "re2":

    cdef cppclass RE2:
        enum Anchor:
            REUNANCHORED "RE2::UNANCHORED"
            ANCHOR_START "RE2::ANCHOR_START"
            ANCHOR_BOTH "RE2::ANCHOR_BOTH"

cdef extern from "re2/stringpiece.h":
    cdef cppclass _StringPiece "re2::StringPiece":
        _StringPiece()
        void set(const char*, size_t)

cdef extern from "re2/set.h" namespace "re2":
    cdef cppclass _Set "RE2::Set":
        _Set(Options, RE2.Anchor)
        int Add(const _StringPiece&, string*)
        bool Compile()
        bool Match(const _StringPiece&, vector[int]*)

    cdef cppclass Options "RE2::Options":
           Options()
           void set_log_errors(int b)

cdef extern from "re2/re2.h" namespace "re2":
    string _QuoteMeta "RE2::QuoteMeta" (const _StringPiece&) 
