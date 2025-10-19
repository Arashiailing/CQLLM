/**
 * @name SimpleXMLRPCServer denial of service
 * @description SimpleXMLRPCServer is vulnerable to denial of service attacks from untrusted user input.
 *              This occurs because the server does not limit the size or complexity of XML documents it processes,
 *              making it susceptible to XML bombs (e.g., exponential entity expansion attacks).
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id py/simple-xml-rpc-server-dos
 * @tags security
 *       experimental
 *       external/cwe/cwe-776
 */

// Import necessary CodeQL libraries for Python code analysis
private import python

// Import Semmle Python concepts library providing language abstractions and patterns
private import semmle.python.Concepts

// Import Semmle API graphs for data flow analysis
private import semmle.python.ApiGraphs

// Identify calls to the SimpleXMLRPCServer class which is vulnerable to XML bomb attacks
from DataFlow::CallCfgNode xmlrpcServerCall
where
  // Check if the current call node is an instantiation of the vulnerable server class
  xmlrpcServerCall = API::moduleImport("xmlrpc").getMember("server").getMember("SimpleXMLRPCServer").getACall()
select xmlrpcServerCall, "SimpleXMLRPCServer is vulnerable to XML bombs."