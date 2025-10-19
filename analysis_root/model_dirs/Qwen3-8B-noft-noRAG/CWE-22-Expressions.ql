import python
import dataflow

/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @id py/Expressions
 */

from CalledMethod, DataFlow::Path
where 
    CalledMethod.name = "os.path.join" or 
    CalledMethod.name = "os.path.abspath" or 
    CalledMethod.name = "os.path.basename" or 
    CalledMethod.name = "os.path.dirname" or 
    CalledMethod.name = "glob.glob" or 
    CalledMethod.name = "open"
    and 
    exists (DataFlow::Source source where source.callees(DataFlow::Path))
select CalledMethod, "Potential path injection vulnerability: untrusted input used in path construction"