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
from DataFlow::CallCfgNode vulnerableServerCall
where 
  // Decompose XML-RPC module access path for clarity
  exists(API::Node xmlrpcModule |
    xmlrpcModule = API::moduleImport("xmlrpc") and
    exists(API::Node serverModule |
      serverModule = xmlrpcModule.getMember("server") and
      exists(API::Node serverClass |
        serverClass = serverModule.getMember("SimpleXMLRPCServer") and
        vulnerableServerCall = serverClass.getACall()
      )
    )
  )
select vulnerableServerCall, "SimpleXMLRPCServer is vulnerable to XML bombs."