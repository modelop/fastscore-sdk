package com.opendatagroup.fastscore.util


case class FastScoreError(message: String, cause: Throwable = None.orNull) extends Exception(message, cause)
