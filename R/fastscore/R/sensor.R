# sensor.py

# class Sensor(object):
#   """
# Represents a FastScore sensor. A sensor can be created directly:
#
# >>> sensor = fastscore.Sensor('sensor-1')
# >>> sensor.desc = {'tap': 'manifold.input.records.size',...}
#
# Or, retreieved from Model Manage:
#
# >>> mm = connect.lookup('model-manage')
# >>> mm.sensors['sensor-1']
# >>> mm.desc
# {...}
#
# """
Sensor <- R6::R6Class("Sensor",
                      public = list(
                        name = NA,
                        source = NA,
                        model_manage = NA,

                        initialize = function(name, source = NA, model_manage = NA){
                          self$name <- name
                          self$source <- source
                          self$model_manage <- model_manage
                        }
                      )
)
