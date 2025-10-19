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

// Identify vulnerable server instantiations through XML-RPC module chain
from DataFlow::CallCfgNode vulnerableRpcServerCall
where 
  // First, locate the XML-RPC module import
  exists(API::Node xmlRpcModule |
    xmlRpcModule = API::moduleImport("xmlrpc") and
    // Then access the server submodule within XML-RPC
    exists(API::Node xmlRpcServerModule |
      xmlRpcServerModule = xmlRpcModule.getMember("server") and
      // Finally, identify the vulnerable SimpleXMLRPCServer class instantiation
      exists(API::Node simpleXmlRpcServerClass |
        simpleXmlRpcServerClass = xmlRpcServerModule.getMember("SimpleXMLRPCServer") and
        vulnerableRpcServerCall = simpleXmlRpcServerClass.getACall()
      )
    )
  )
select vulnerableRpcServerCall, "SimpleXMLRPCServer is vulnerable to XML bombs."