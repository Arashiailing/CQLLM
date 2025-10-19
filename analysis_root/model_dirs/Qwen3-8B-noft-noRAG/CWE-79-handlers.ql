import python
import semmle.code.cpp.dataflow.DataFlow

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/handlers
 */

from MethodCall, StringLiteral, Parameter
where 
    // Identify potential sources of user input (e.g., request parameters)
    MethodCall.getTarget(MethodCall) = "request.args" and
    MethodCall.getFunctionName() = "get" and
    Parameter.getParameterIndex() = 0
    
    // Find direct output to HTTP response (e.g., print, write, or return statements)
    and exists(
        Call c
        | c.getKind() = "call" and
          c.getExpression().getFullyQualifiedName() = "flask.Response" and
          c.getArgument(0).getToString() = "html"
    )
    
    // Trace data flow from source to sink without proper escaping
    and dataFlow::isDataFlowPath(
        StringLiteral.getStringValue(),
        c.getArgument(0).getToString()
    )

select StringLiteral, "Potential reflected XSS vulnerability: User input is directly written to HTML response without proper sanitization."