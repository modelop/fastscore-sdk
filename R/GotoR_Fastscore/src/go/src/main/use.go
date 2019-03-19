package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "gopkg.in/yaml.v2"
	  "io/ioutil"
	  "path/filepath"
	  "github.com/mitchellh/go-homedir"
)

//export Use
func Use(enginename *C.char) *C.char{
  connect := sdk.NewConnect(proxy_path)
  instanceinfo, err := connect.Fleet()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	enginePresent :=false
	for _, v := range instanceinfo {
		if C.GoString(enginename) == v.Name {
				enginePresent = true
				break
		}
	}
	if ! enginePresent {
		return C.CString("Fastscore Error --- Engine not present.")
	}
	
	config, _ := GetCfg()

	config.Preferred.Engine = C.GoString(enginename)
	config.TargetName = C.GoString(enginename) // Why do we use target and preferred?

	d, err := yaml.Marshal(&config)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	home, err := homedir.Dir()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	err = ioutil.WriteFile(filepath.Join(home, ".fastscore"), d, 0644)

	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Done.")
	}
}