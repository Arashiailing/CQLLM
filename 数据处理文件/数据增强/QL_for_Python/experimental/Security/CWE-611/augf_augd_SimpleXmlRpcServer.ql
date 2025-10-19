/**
 * @name SimpleXMLRPCServer denial of service
 * @description Detects usage of SimpleXMLRPCServer which is vulnerable to XML bomb denial-of-service attacks
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

from DataFlow::CallCfgNode xmlRpcServerCall
where
  // Identify vulnerable SimpleXMLRPCServer instantiation
  exists(API::Node xmlrpcModule |
    xmlrpcModule = API::moduleImport("xmlrpc") and
    exists(API::Node serverModule |
      serverModule = xmlrpcModule.getMember("server") and
      exists(API::Node serverClass |
        serverClass = serverModule.getMember("SimpleXMLRPCServer") and
        xmlRpcServerCall = serverClass.getACall()
      )
    )
  )
select xmlRpcServerCall, "SimpleXMLRPCServer is vulnerable to XML bomb denial-of-service attacks"