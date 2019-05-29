package main
import (
    "C"
    "os"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "gopkg.in/yaml.v2"
)

//export Config_show
func Config_show() *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	cfg, err := connect.GetConfig()  // get Configuration
	
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	d, err := yaml.Marshal(&cfg)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	return C.CString(string(d))
}

//export Config_set
func Config_set(path *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	file, err := os.Open(C.GoString(path))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	err = connect.SetConfig(file)
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Configuration set.")
	}
}