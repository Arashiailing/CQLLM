/**
* @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
*
@id py/chroot
*/
import python
import external.VCS
from File sourceFile, string entity
    where exists(PackageObject package, AstNode src | dependency(src, package)
    and src.getLocation().getFile() = sourceFile
    and entity = munge(sourceFile, package) )
    select entity, sourceFile