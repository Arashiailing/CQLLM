import python

/**
 * A query to detect CWE-94: Code Injection vulnerabilities in Python code.
 * This query looks for cases where user input is directly used in an XML-RPC call.
 */

from XmlRpcCall xmlRpcCall, Expr userInputExpr
where xmlRpcCall.getArgument(0) = userInputExpr and userInputExpr instanceof UserInput
select xmlRpcCall, "This XML-RPC call uses unsanitized user input, which may lead to code injection."