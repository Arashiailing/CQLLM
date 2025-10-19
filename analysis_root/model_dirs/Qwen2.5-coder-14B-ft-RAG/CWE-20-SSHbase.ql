/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/SSHbase
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode bindCall, DataFlow::Node addressArg, string hostname
where
  bindCall = socketInstance().getMember("bind").getACall() and
  addressArg = bindCall.getArg(0) and
  addressArg = vulnerableAddressTuple(hostname)
select bindCall.asExpr(), "'" + hostname + "' binds a socket to all interfaces."