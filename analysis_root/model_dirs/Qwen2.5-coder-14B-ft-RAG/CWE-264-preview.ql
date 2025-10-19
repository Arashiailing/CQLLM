/**
 * @name CWE CATEGORY: Permissions, Privileges, and Access Controls
 * @description nan
 * @kind rule
 * @problem.severity recommendation
 * @tags correctness
 */

import python
import semmle.python.Concepts

from Function f
where f.isNamed("__init__")
select f, "Class constructor named '__init__' may conflict with __init__.py in a subdirectory."