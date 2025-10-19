import python
import semmle.code.all
import semmle.python.security.dataflow

/**
 * @name URLRedirectionFromRemoteSource
 * @description Detects potential URL redirection vulnerabilities where user input is used to construct a redirect URL without validation.
 */
predicate isUnsanitizedRedirectArgument(String argName, String redirectFunction) {
    // Check if the argument is derived from user input sources
    exists (DataFlow::DataFlowNode src, DataFlow::DataFlowNode dst |
        dataFlows(src, dst, "python.stdlib") and
        src.getDefinition() = getArgument(argName) and
        dst.getLocation().getCallExpression().toString() = redirectFunction and
        not exists (StringFilter filter | 
            filter.getExpression() = dst.getLocation().getCallExpression().toString() and
            filter.getFilterType() = "whitelist" or
            filter.getFilterType() = "lengthCheck"
        )
    )
}

from CallExpr call, Argument arg, String redirectFunc
where
    call.getName() = redirectFunc and
    arg.getArgNumber() = 0 and
    isUnsanitizedRedirectArgument(arg.getName(), redirectFunc)
select call, "Potential URL redirection vulnerability: User input used in redirect without validation."