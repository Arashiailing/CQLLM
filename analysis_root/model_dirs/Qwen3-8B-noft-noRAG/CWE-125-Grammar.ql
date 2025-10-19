import semmle.code.py.Python
import semmle.code.cpp.Expressions

from SliceExpr slice, CallExpr call
where
  call.getTarget() = "str"
  and call.getArg(0) = slice
  and exists(UserInput input |
    slice.getStart() = input
    or slice.getEnd() = input)
select slice, "Potential out-of-bounds read due to unbounded user input in string slicing."