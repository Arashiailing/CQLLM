/**
* @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
*
@description This query detects potential vulnerabilities related to improper link resolution before file access.
*
@id py/daemonizer
*
@tags security
*/
import python
import experimental.Security.LinkResolution
from File sourceFile, string entity
    where exists(LinkResolution::LinkNode source, LinkResolution::LinkNode sink | LinkResolution::follows(source, sink)
    and source.getLocation().getFile() = sourceFile
    and entity = munge(sourceFile, sink) )
    select entity, sourceFile, "Potential vulnerability due to improper link resolution before file access."