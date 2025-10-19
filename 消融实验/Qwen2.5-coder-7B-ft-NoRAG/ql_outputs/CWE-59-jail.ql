/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/jail
 */

import python
import external.VCS

from File sourceFile, string entity
where
  exists(PackageObject package, AstNode src |
    dependency(src, package) and
    src.getLocation().getFile() = sourceFile and
    entity = munge(sourceFile, package)
  )
select entity, sourceFile, "Improper link resolution before file access detected."