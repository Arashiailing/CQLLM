import python

/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description Detects potential uncontrolled resource consumption issues such as infinite loops and unclosed resources.
 */
from WhileStmt w
where w.get_condition().is_true()
select w, "Potential infinite loop due to always-true condition in while loop."

from OpenStmt o
where not exists (CloseStmt c where c.get_file() = o.get_file())
select o, "File handle not closed, leading to potential resource exhaustion."

from ForStmt f
where f.get_iter().is_infinite()
select f, "Potential infinite loop in for loop with unbounded iteration."

from FunctionCall fc
where fc.get_name() = "open" and not exists (Call c where c.get_method() = "close" and c.get_receiver() = fc.get_receiver())
select fc, "File opened but not closed, risking resource exhaustion."