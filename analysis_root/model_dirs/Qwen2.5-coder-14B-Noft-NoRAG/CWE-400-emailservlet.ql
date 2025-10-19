import java

/**
 * CWE-400: Uncontrolled Resource Consumption
 * Detects potential uncontrolled resource consumption in Java applications.
 */

class UncontrolledResourceConsumption extends Method {
  UncontrolledResourceConsumption() {
    this.getName() = "doGet" or this.getName() = "doPost"
  }

  boolean hasUncontrolledResourceConsumption() {
    exists(Expr e |
      e instanceof MethodCall and
      e.getMethod().getName() = "readLine" and
      not exists(Expr limit | limit instanceof Literal and e.getArgument(0) = limit)
    )
  }
}

from UncontrolledResourceConsumption method
where method.hasUncontrolledResourceConsumption()
select method, "This method may be vulnerable to CWE-400: Uncontrolled Resource Consumption due to uncontrolled resource consumption in the readLine method."