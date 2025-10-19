import python

/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @id py/server
 */

from MethodCall, Parameter
where 
    MethodCall.name = "open" and 
    Parameter.value = "file_path" and 
    // Check for potential unbounded file operations
    exists (Parameter p | p.value = "mode" and p.value = "r" or p.value = "w") and
    // Look for lack of resource cleanup
    not (MethodCall.isInlined or MethodCall.isClosed)
select MethodCall, "Potential uncontrolled resource consumption due to unclosed file handle"