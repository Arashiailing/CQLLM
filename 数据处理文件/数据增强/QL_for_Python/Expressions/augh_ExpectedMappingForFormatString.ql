/**
 * @name Formatted object is not a mapping
 * @description Detects when a format string with named specifiers is used with a non-mapping object, causing TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/not-mapping
 */

import python
import semmle.python.strings

from Expr rhsExpr, ClassValue rhsClass
where
  exists(BinaryExpr modExpr | 
    modExpr.getOp() instanceof Mod and
    rhsExpr = modExpr.getRight() and
    format_string(modExpr.getLeft()) and
    mapping_format(modExpr.getLeft()) and
    rhsExpr.pointsTo().getClass() = rhsClass and
    not rhsClass.isMapping()
  )
select rhsExpr, 
       "Right operand of % operator must be a mapping, not class $@.", 
       rhsClass, 
       rhsClass.getName()