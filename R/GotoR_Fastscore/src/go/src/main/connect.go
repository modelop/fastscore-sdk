package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "strings"
)

var proxy_path = "https://localhost:8000"

//export Connect
func Connect(path *C.char) *C.char{
  proxyprefix := C.GoString(path)
  // Allow http calls
	// Adding checks on proxy prefix to avoid invalid URLs
	if !strings.Contains(proxyprefix, "://") {
		return C.CString("Fastscore Error --- Proxy prefix must be an URL, e.g. https://dashboard:8000")
	}
	if !strings.HasPrefix(proxyprefix, "https:") && !strings.HasPrefix(proxyprefix, "http:") {
		return C.CString("Fastscore Error --- Proxy prefix must use HTTPS scheme")
	}
	last := proxyprefix[len(proxyprefix)-1:]
	if last == "/" {
		proxyprefix = proxyprefix[:len(proxyprefix)-1]
	}
  
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  r, err := con.Health()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  return C.CString("proxy prefix: " + proxy_path + ". Built on " + r.BuiltOn)
}