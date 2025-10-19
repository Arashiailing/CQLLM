/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@description Exposing sensitive information in settings files can lead to unauthorized access.
*
@id py/settings
*/
import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.security.dataflow.SettingsExposureQuery
import SettingsExposureFlow::PathGraph
from SettingsExposureFlow::PathNode source, SettingsExposureFlow::PathNode sink, string classification
    where SettingsExposureFlow::flowPath(source, sink)
    and classification = source.getNode().(Source).getClassification()
    select sink.getNode(), source, sink, "Sensitive information ($@) exposed in settings file.", source.getNode(), classification