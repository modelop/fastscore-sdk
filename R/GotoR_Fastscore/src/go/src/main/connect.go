package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "strings"
)

var proxy_path = "https://localhost:8000"

//export Connect
func Connect(path *C.char) *C.char{
  proxy_path= C.GoString(path)
  // Allow http calls
	// Adding checks on proxy prefix to avoid invalid URLs
	if !strings.Contains(proxy_path, "://") {
		return C.CString("Fastscore Error --- Proxy prefix must be an URL, e.g. https://dashboard:8000")
	}
	if !strings.HasPrefix(proxy_path, "https:") && !strings.HasPrefix(proxy_path, "http:") {
		return C.CString("Fastscore Error --- Proxy prefix must use HTTPS scheme")
	}
	last := proxy_path[len(proxy_path)-1:]
	if last == "/" {
		proxy_path = proxy_path[:len(proxy_path)-1]
	}
  
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  r, err := con.Health()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  return C.CString("proxy prefix: " + proxy_path + ". Built on " + r.BuiltOn)
}