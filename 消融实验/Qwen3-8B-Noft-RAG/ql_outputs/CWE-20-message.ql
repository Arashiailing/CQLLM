import python
import semmle.python.security.dataflow.CookieInjectionQuery
import semmle.python.security.dataflow.CommandInjectionQuery
import semmle.python.security.dataflow.UnsafeDeserializationQuery
import semmle.python.security.dataflow.XpathInjectionQuery
import semmle.python.security.dataflow.PolynomialReDoSQuery
import semmle.python.security.dataflow.ZipSlip

import CookieInjectionFlow::PathGraph
import CommandInjectionFlow::PathGraph
import UnsafeDeserializationFlow::PathGraph
import XpathInjectionFlow::PathGraph
import PolynomialReDoSFlow::PathGraph
import ZipSlipFlow::PathGraph

from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink
where CookieInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected."

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected."

from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected."

from XpathInjectionFlow::PathNode source, XpathInjectionFlow::PathNode sink
where XpathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected."

from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink
where PolynomialReDoSFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected."

from ZipSlipFlow::PathNode source, ZipSlipFlow::PathNode sink
where ZipSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper input validation detected."