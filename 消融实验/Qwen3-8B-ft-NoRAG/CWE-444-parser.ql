import python

from SplitExpr import SplitExpr
where SplitExpr.get_str() = "split('\n')" or SplitExpr.get_str() = "split('\n\n')"
select SplitExpr, "Potential HTTP Header Injection due to incorrect line separator."