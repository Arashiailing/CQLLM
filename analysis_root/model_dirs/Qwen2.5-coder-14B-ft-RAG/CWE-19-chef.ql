/**
 * @name CWE CATEGORY: Data Processing Errors
 * @description nan
 * @kind problem
 * @id py/chef
 */

import python
import semmle.python.ApiGraphs

from Class cls
where
  cls.getName() = "Chef"
select cls, "The class 'Chef' has been deprecated."