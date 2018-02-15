package com.opendatagroup.fastscore.assets

/** Constants
  *
  */
object Constants {
    /** Model format to content type
      *
      */
    val MODEL_CONTENT_TYPES = Map(
        "pfa-json" ->   "application/vnd.fastscore.model-pfa+json",
        "pfa-yaml" ->   "application/vnd.fastscore.model-pfa-yaml",
        "pfa-pretty" -> "application/vnd.fastscore.model-pfa-pretty",
        "h2o-java" ->   "application/vnd.fastscore.model-h2o-java",
        "python" ->     "application/vnd.fastscore.model-python",
        "python3" ->    "application/vnd.fastscore.model-python3",
        "R" ->          "application/vnd.fastscore.model-r",
        "java" ->       "application/vnd.fastscore.model-java",
        "c" ->          "application/vnd.fastscore.model-c",
        "octave" ->     "application/vnd.fastscore.model-m"
    )

    /** Canonical model file extension to model format
      *
      */
    val MODEL_FORMAT_EXT = Map(
        ".pfa" ->       "pfa-json",
        ".ppfa" ->      "pfa-pretty",
        ".py" ->        "python",
        ".R" ->         "R",
        ".java" ->      "java",
        ".c" ->         "c",
        ".m" ->         "octave"
    )

    /** Canonical attachment file extension to content type
      *
      */
    val ATTACHMENT_CONTENT_TYPES = Map(
        "zip" ->  "application/zip",
        "tgz" ->  "application/gzip"
    )

    /** Schema content type
      *
      */
    val SCHEMA_CONTENT_TYPE = "application/vnd.fastscore.schema-avro"

    /** Policy format to content type
      *
      */
    val POLICY_CONTENT_TYPES = Map(
        "python" ->   "application/vnd.fastscore.import-policy-python",
        "python3" ->  "application/vnd.fastscore.import-policy-python3",
        "r" ->        "application/vnd.fastscore.import-policy-r",
        "java" ->     "application/vnd.fastscore.import-policy-java",
        "c" ->        "application/vnd.fastscore.import-policy-c"
    )

    /** Default input slot number
      *
      */
    val DEFAULT_INPUT_SLOTNO = 0

    /** Default output slot number
      *
      */
    val DEFAULT_OUTPUT_SLOTNO = 1
}