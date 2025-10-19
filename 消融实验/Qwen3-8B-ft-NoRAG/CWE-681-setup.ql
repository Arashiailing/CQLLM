import semmle.code.py.PyCodeQL

from PyFunctionCall call, PyModule mathModule, PyConstant nanConstant
where mathModule.getName() = "math" and nanConstant.getName() = "nan"
  and call.getFunctionName() in ["int", "float", "str", "bool"]
  and call.getArgument(0) = nanConstant
select call, "The conversion of math.nan to " + call.getFunctionName() + " is invalid."