package com.opendatagroup.fastscore.assets

object Constants {
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

    val MODEL_FORMAT_EXT = Map(
        ".pfa" ->       "pfa-json",
        ".ppfa" ->      "pfa-pretty",
        ".py" ->        "python",
        ".R" ->         "R",
        ".java" ->      "java",
        ".c" ->         "c",
        ".m" ->         "octave"
    )

    val ATTACHMENT_CONTENT_TYPES = Map(
        "zip" ->  "application/zip",
        "tgz" ->  "application/gzip"
    )

    val SCHEMA_CONTENT_TYPE = "application/vnd.fastscore.schema-avro"

    val POLICY_CONTENT_TYPES = Map(
        "python" ->   "application/vnd.fastscore.import-policy-python",
        "python3" ->  "application/vnd.fastscore.import-policy-python3",
        "r" ->        "application/vnd.fastscore.import-policy-r",
        "java" ->     "application/vnd.fastscore.import-policy-java",
        "c" ->        "application/vnd.fastscore.import-policy-c"
    )
}