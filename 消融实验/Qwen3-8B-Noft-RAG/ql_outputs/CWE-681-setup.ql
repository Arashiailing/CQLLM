import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.python.security.dataflow.TypeConversionFlow

from Conversion conversion
where conversion.getSourceType() = "float" and conversion.getTargetType() = "int"
select conversion, "Incorrect conversion from float to int may propagate NaN values."