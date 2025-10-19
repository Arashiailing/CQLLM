/**
 * @name CWE-522: Insufficiently Protected Credentials
 * @description Storing credentials in cleartext can expose sensitive information to unauthorized users.
 * @kind problem
 * @tags security
 *       external/cwe/cwe-522
 *       external/cwe/cwe-315
 * @problem.severity error
 * @sub-severity high
 * @precision medium
 * @id py/clear-text-credentials
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

predicate cleartextStore(DataFlow::Node store, string location) {
  (
    store = DataFlow::ModuleImportNode::moduleImport("configparser").getMember("RawConfigParser").getReturn()
    or
    store = DataFlow::ModuleImportNode::moduleImport("configparser").getMember("SafeConfigParser").getReturn()
    or
    store = DataFlow::ModuleImportNode::moduleImport("configparser").getMember("ConfigParser").getReturn()
  )
  and
  location = "config parser"
  or
  store = DataFlow::ModuleImportNode::moduleImport("distutils.config").getMember("ConfigParser").getReturn()
  and
  location = "config parser"
  or
  store = DataFlow::ModuleImportNode::moduleImport("json").getMember("dumps").getReturn()
  and
  location = "JSON encoder"
}

from DataFlow::Node credSrc, DataFlow::Node store, string location
where
  cleartextStore(store, location) and
  (
    credSrc = store.getScope().getMember("read").getACall().getNode()
    or
    credSrc = store.getScope().getMember("parse").getACall().getNode()
  )
select store, "Storing credentials using " + location + "."