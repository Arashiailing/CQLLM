/**
 * @deprecated
 * @name Out-of-bounds read
 * @kind problem
 * @problem.severity error
 * @precision very-high
 * @id py/out-of-bounds-read
 * @tags reliability
 */

import python

predicate out_of_bounds_read(DataFlow::CallCfgNode c) {
  exists(int i, DataFlow::Node arg |
    c = c.getFunction().getMember("read").getACall() and
    arg = c.getArg(i) and
    not arg instanceof ImmutableLiteral
  )
}

from DataFlow::CallCfgNode call
where out_of_bounds_read(call)
select call.asExpr(), "Out-of-bounds read"