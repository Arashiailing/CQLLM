/**
* @name CWE-264: TarSlipQuery
*
@description Extracting files
from a malicious tar file without validating that the destination file path is within the destination directory can allow an attacker to unexpectedly gain access to resources.
* @kind path-problem
*
@id py/archiver
* @problem.severity error
* @security-severity 7.5
* @precision high
*
@tags security
*/
import python
import experimental.semmle.python.security.ZipSlip
import ZipSlipFlow::PathGraph
from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
    where ZipSlipFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Extraction of tarfile
from $@ to a potentially untrusted source $@.", source.getNode(), source.getNode().toString(), sink.getNode(), sink.getNode().toString()