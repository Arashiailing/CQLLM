/**
 * @name Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/auth-flaw
 * @tags security
 *       external/cwe/cwe-287
 */

import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

class SecretSource extends DataFlow::Node {
  SecretSource() {
    ApiNode::moduleImport("gnupg").getMember("GPG").getReturn()
     .flowsTo(this)
    or
    exists(ApiNode keyring |
      keyring = ApiNode::moduleImport("gnupg").getMember("GPG")
           .getReturn()
           .getMember("keyrings")
           .getReturn()
           .getMember(".")
           .getReturn()
           .getMember("__getitem__")
           .getReturn()
           .getACall()
           .getNode()
      and
      keyring.getArgByName("filename").flowsTo(this)
    )
  }

  override string toString() { result = "secret source" }
}

class NonConstantTimeComparisonSink extends DataFlow::Node {
  NonConstantTimeComparisonSink() {
    exists(SecretSource src, DataFlow::CompareNode cmp |
      cmp.compare(src, any(In i), _)
      or
      cmp.compare(any(In i), src, _)
      or
      cmp.compare(src, _, _)
      or
      cmp.compare(_, src, _)
      |
      this = cmp
    )
  }

  override string toString() { result = "non-constant time comparison sink" }
}

module TimingAttackAgainstSensitiveInfoConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node src) { src instanceof SecretSource }

  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }

  predicate observeDiffInformedIncrementalMode() { any() }
}