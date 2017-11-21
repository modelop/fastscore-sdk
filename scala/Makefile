
.PHONY: clean build

OUT_DIR := fastscore

JAVA_OPTS := -DapiTests=false -DmodelTests=false

build:
	cd fastscore && sbt clean compile

clean:
	cd fastscore && sbt clean

# v1-api: ../api/suite-proxy-v1.yaml
# 	sed -i -scala 's/binary/ByteArray/g' ../api/suite-proxy-v1.yaml
# 	swagger-codegen generate \
#     -i $^-scala \
#     -l scala \
#     -c cg-v1.json \
#     -o $(OUT_DIR)
# 	rm -f $^-scala
# 	find ./fastscore/ -type f -exec sed -i '' -E 's/: AnyRef = ([A-Z]|[a-z]+)/:AnyRef = \1.asInstanceOf[AnyRef]/' {} \;
# 	find ./fastscore/ -type f -exec sed -i '' 's/&#x60;//g' {} \;
# 	find ./fastscore/ -type f -exec sed -i '' 's/return: /_return: /g; s/`return`/`_return`/g' {} \;
# 	find ./fastscore/ -type f -exec sed -i '' 's/"fields"/"return"/g' {} \;
# 	// TODO REPLACE INSTANCE CASTING TO ANY FROM STRING IN MM.SCHEMALIST
# 	sed -i '' 's/Some(apiInvoker.deserialize(s, "array", classOf[String]).asInstanceOf[List[String]])/\
# 	Some(apiInvoker.deserialize(s, "array", classOf[Any]).asInstanceOf[List[Any]])/g' \
# 	./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/api1/ModelManageApi.scala
# 	sed -i '' 's/def schemaList(instance: String): Option[List[String]]/\
# 	def schemaList(instance: String): Option[List[Any]]/g' \
# 	./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/api1/ModelManageApi.scala
# 	sed -i '' 's/def schemaList(instance: String): Option[List[String]]/\
# 	def schemaList(instance: String): Option[List[Any]]/' \
# 	./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/invoker1/ApiInvoker.scala

# 	# invokerPackage does not move to the right folder
# 	mkdir -p ./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/invoker1/
# 	mv ./fastscore/src/main/scala/io/swagger/client/ApiInvoker.scala ./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/invoker1/ApiInvoker.scala
# 	rm -rf ./fastscore/src/main/scala/io
# 	sed -i '' 's/def escape(value: UUID): String = value.toString/def escape(value: UUID): String = value.toString;\
# 		def escape(value: Integer): String = value.toString/' \
# 	./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/invoker1/ApiInvoker.scala
	

# v2-api: ../api/suite-proxy-v2.yaml
# 	sed -i -scala 's/binary/ByteArray/g' ../api/suite-proxy-v2.yaml
# 	swagger-codegen generate \
#     -i $^-scala \
#     -l scala \
#     -c cg-v2.json \
#     -o $(OUT_DIR)
# 	rm -f $^-scala
# 	find ./fastscore/ -type f -exec sed -i '' -E 's/: AnyRef = ([A-Z]|[a-z]+)/:AnyRef = \1.asInstanceOf[AnyRef]/' {} \;
# 	mkdir -p ./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/invoker2/
# 	mv ./fastscore/src/main/scala/io/swagger/client/ApiInvoker.scala ./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/invoker2/ApiInvoker.scala
# 	rm -rf ./fastscore/src/main/scala/io
# 	sed -i '' 's/def escape(value: UUID): String = value.toString/def escape(value: UUID): String = value.toString;\
# 		def escape(value: Integer): String = value.toString/' \
# 	./fastscore/src/main/scala/com/opendatagroup/fastscore/swagger/invoker2/ApiInvoker.scala