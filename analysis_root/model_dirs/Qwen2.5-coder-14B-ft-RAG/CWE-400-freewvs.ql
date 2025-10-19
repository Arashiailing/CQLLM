/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind problem
 * @tags reliability
 *       correctness
 *       maintainability
 *       non-attributable
 * @problem.severity warning
 * @sub-severity low
 * @precision medium
 * @id py/freewvs
 */

import python
import semmle.python.Concepts
import FreeVariableReference
import semmle.python.pointsto.PointsTo
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.Definitions

// Helper predicate to check if a variable has a reference chain ending at the same variable
predicate hasRefChain(Variable var) {
  exists(ControlledResourceVariable v | 
    PointsTo::flowto(v.getAnAccess(), var.getAnAccess()) and
    freeVariableReference(var)
  )
}

// Main query selecting problematic variables based on their reference chains
from Variable var
where hasRefChain(var)
select var, "Uncontrolled resource consumption due to unbounded references."