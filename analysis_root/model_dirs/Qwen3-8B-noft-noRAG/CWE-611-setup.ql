import python

/**
 * @name XML external entity expansion
 * @description Parsing user input as an XML document with external
 * entity expansion is vulnerable to XXE attacks.
 * @id py/setup
 */

predicate isXmlExternalEntityExpansion(
    MethodCall callee,
    Expr arg
) {
    // Check for ElementTree usage with resolve_entities enabled
    (callee.getMethod() = "XMLParser" and
     callee.getArg(0).hasType("xml.etree.ElementTree.XMLParser") and
     exists(StringLiteral s | callee.getArg(0).getValue() = s and
             s.getValue() = "resolve_entities" and
             callee.getArg(1).isBoolLiteral(true)))

    or 

    // Check for lxml usage with dtd parsing enabled
    (callee.getMethod() = "fromstring" and
     callee.getArg(0).hasType("lxml.etree._ElementTree") and
     exists(StringLiteral s | callee.getArg(0).getValue() = s and
             s.getValue() = "forbid_dtd" and
             callee.getArg(1).isBoolLiteral(false)))

    or 

    // Check for Entity Resolver setup
    (callee.getMethod() = "setEntityResolver" and
     callee.getArg(0).hasType("xml.etree.ElementTree.EntityResolver"))
}

from MethodCall m
where isXmlExternalEntityExpansion(m, null)
select m.getLocation(), "Potential XXE vulnerability: XML parser configured to allow external entities"