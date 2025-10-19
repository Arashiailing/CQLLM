/**
 * @name CWE-835: Loop with Unreachable Exit Condition ('Infinite Loop')
 * @description The product contains an iteration or loop with an exit condition that cannot be reached, i.e., an infinite loop.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-loop-condition
 */

import python

from While loop
where not reachable_exit_condition(loop)
select loop, "This loop may never terminate."