class AvroException(RuntimeError):
    """Exception for errors in deserializing or serializing Avro data."""
    pass

class SchemaParseException(RuntimeError):
    """Exception for errors in parsing an Avro schema."""
    pass

class FastScoreException(RuntimeError):
    """Exception for errors occuring in FastScore."""
    pass
