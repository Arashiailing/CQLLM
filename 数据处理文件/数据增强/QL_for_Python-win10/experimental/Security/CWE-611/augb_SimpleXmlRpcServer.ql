/**
 * @name SimpleXMLRPCServer denial of service
 * @description Detects vulnerable SimpleXMLRPCServer instances susceptible to XML bomb denial-of-service attacks
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id py/simple-xml-rpc-server-dos
 * @tags security
 *       experimental
 *       external/cwe/cwe-776
 */

// Core Python language analysis framework
private import python

// Semantic analysis components for Python constructs
private import semmle.python.Concepts

// API graph construction for data flow tracking
private import semmle.python.ApiGraphs

// Identify vulnerable server instantiations
from DataFlow::CallCfgNode serverInstanceCall
where
  // Trace to SimpleXMLRPCServer class through xmlrpc.server module
  serverInstanceCall = API::moduleImport("xmlrpc")
    .getMember("server")
    .getMember("SimpleXMLRPCServer")
    .getACall()
select serverInstanceCall, "SimpleXMLRPCServer is vulnerable to XML bombs."