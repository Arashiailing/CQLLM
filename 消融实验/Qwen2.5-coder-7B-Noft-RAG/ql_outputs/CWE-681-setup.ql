/**
* @name CWE-681: Incorrect Conversion between Numeric Types
*
@description Incorrect conversion between numeric types may lead to unexpected results.
* @kind path-problem
* @problem.severity warning
* @precision high
*
@id py/nan
*/
import python
import semmle.python.dataflow.NumericConversion
from NumericConversion::NumericConversionNode src, NumericConversion::NumericConversionNode tgt
    where NumericConversion::conversion(src, tgt)
    select tgt, src, tgt, "Potential incorrect conversion between numeric types."