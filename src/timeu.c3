module timeu;
import std::io;

extern fn CLong ctime_ms();

macro @timeit(;@body()){
  CLong t = ctime_ms();
  @body();
  CLong tn = ctime_ms();
  return (long)tn - (long)t;
}
