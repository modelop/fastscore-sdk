package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
)

var proxy_path = "https://localhost:8000"

//export Connect
func Connect(path *C.char) *C.char{
  proxy_path = C.GoString(path)
  con := sdk.NewConnect(proxy_path)
  r, err := con.Health()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  return C.CString("proxy prefix: " + proxy_path + ". Built on " + r.BuiltOn)
}