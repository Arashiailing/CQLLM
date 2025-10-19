import python
import experimental.semmle.python.security.InsecureRandomness

from Call c
where InsecureRandomness::isInsufficientlyRandom(c)
select c, "Use of insufficiently random values in sensitive context"