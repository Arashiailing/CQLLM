import python
import semmle.code.java.dataflow.DataFlow

from PrintStmt ps, ExceptHandler eh
where eh.getStatements().contains(ps)
select ps, "Potential stack trace exposure in exception handling"

import python
import semmle.code.java.dataflow.DataFlow

from CallExpr ce, ExceptHandler eh
where eh.getStatements().contains(ce) 
  and ce.getCalleeName() = "print" 
  and ce.getNumArgs() > 0 
  and exists(Arg arg | ce.getArg(0) = arg and arg.isName() and arg.getName() = "e")
select ce, "Potential stack trace exposure through print statement in exception handling"

import python
import semmle.code.java.dataflow.DataFlow

from CallExpr ce, ExceptHandler eh
where eh.getStatements().contains(ce) 
  and ce.getCalleeName() = "logger" 
  and ce.getMethodName() = "exception"
select ce, "Potential stack trace exposure via logging.exception in exception handling"

import python
import semmle.code.java.dataflow.DataFlow

from CallExpr ce
where ce.getCalleeName() = "sys" 
  and ce.getMethodName() = "exc_info" 
  and exists(CallExpr c | c.getCalleeName() = "print" and c.getArg(0).isName() and c.getArg(0).getName() = "exc_info()")
select ce, "Potential stack trace exposure via sys.exc_info usage"