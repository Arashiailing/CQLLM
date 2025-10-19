/**
 * @name Raising a tuple
 * @description Raising a tuple will result in all but the first element being discarded
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/raises-tuple
 */

import python
import semmle.python.dataflow.new.DataFlow

// 从Raise类中选择r，并从DataFlow::LocalSourceNode类中选择origin
from Raise r, DataFlow::LocalSourceNode origin
where
  // 存在一个DataFlow::Node类型的exception，并且该exception的表达式等于r.getException()，且origin流到exception
  exists(DataFlow::Node exception | exception.asExpr() = r.getException() |
    origin.flowsTo(exception)
  ) and
  // origin的表达式是一个Tuple类型
  origin.asExpr() instanceof Tuple and
  // Python的主版本号是2
  major_version() = 2
/* Raising a tuple is a type error in Python 3, so is handled by the IllegalRaise query. */
select r,
  "Raising a $@ will result in the first element (recursively) being raised and all other elements being discarded.",
  origin, "tuple"
