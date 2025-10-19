import python

/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description Detects uncontrolled resource consumption vulnerabilities in Python code.
 */
query CWE_400_Uncontrolled_Resource_Consumption() {
  // Find potential infinite loops that could consume CPU resources
  (from LoopStmt loop
   where loop.isForLoop() or loop.isWhileLoop()
     and not exists BreakStmt b where b.getParent() = loop
     and not exists ContinueStmt c where c.getParent() = loop
     and not exists ReturnStmt r where r.getParent() = loop
   select loop, "Potential infinite loop detected"))

  // Find unclosed file handles
  (from CallExpr openCall
   where openCall.getCallee().getName() = "open"
   and not exists CallExpr closeCall
      where closeCall.getCallee().getName() = "close"
        and closeCall.getArgument(0).getValue() = openCall.getArgument(0).getValue()
   select openCall, "Unclosed file handle detected"))

  // Find excessive memory allocations without limits
  (from CallExpr allocCall
   where allocCall.getCallee().getName() = "list" or allocCall.getCallee().getName() = "dict"
     and exists Expr expr
       where expr.toString() =~ /^\d+$/
         and expr.getIntValue() > 1000000
   select allocCall, "Excessive memory allocation detected"))
}