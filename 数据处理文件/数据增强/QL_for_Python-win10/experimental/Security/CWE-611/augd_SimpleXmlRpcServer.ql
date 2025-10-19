/**
 * @name SimpleXMLRPCServer denial of service
 * @description SimpleXMLRPCServer is vulnerable to denial of service attacks from untrusted user input
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id py/simple-xml-rpc-server-dos
 * @tags security
 *       experimental
 *       external/cwe/cwe-776
 */

// Import Python library for code analysis
private import python

// Import Semmle Python concepts for language abstractions and patterns
private import semmle.python.Concepts

// Import Semmle API graphs for data flow analysis
private import semmle.python.ApiGraphs

from DataFlow::CallCfgNode vulnerableServerCall
where
  // Identify calls to SimpleXMLRPCServer, which is vulnerable to XML bomb attacks
  vulnerableServerCall = API::moduleImport("xmlrpc")
                              .getMember("server")
                              .getMember("SimpleXMLRPCServer")
                              .getACall()
select vulnerableServerCall, "SimpleXMLRPCServer is vulnerable to XML bombs."