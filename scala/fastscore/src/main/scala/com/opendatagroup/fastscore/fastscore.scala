package com.opendatagroup

/** An example interaction with FastScore
  * {{{
  *     scala> import com.opendatagroup.fastscore.fleet._
  *     scala> implicit val proxy = new Proxy("https://localhost:8000")
  *     scala> val connect = new Connect()
  *     scala> import com.opendatagroup.fastscore.assets._
  *     scala> val model = Model.fromFile("./preprocessor.R")
  *     scala> val modelmanage = connect.lookup("model-manage") match { case l: List[ModelManage] if l.length == 1 => l(0) }
  *     scala> modelmanage.models.put("preprocessor", model)
  * }}}
  */
package object fastscore {}