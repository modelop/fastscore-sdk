package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "github.com/opendatagroup/fastscore-sdk-go/sdk/swagger"
    "encoding/json"
    "io/ioutil"
    "gopkg.in/yaml.v2"
)

//export Composer_list
func Composer_list() *C.char {
  con := sdk.NewConnect(proxy_path)
  composer, err := con.LookupComposer()
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }
  wfs, err := composer.Workflows()
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }
  
  var res []string
  for _, name := range wfs {
    res = append(res, name)
  }
	
  return C.CString(ArrayToString(res))
}

//export Composer_create
func Composer_create(name *C.char, path *C.char) *C.char {
  con := sdk.NewConnect(proxy_path)
  file, err := ioutil.ReadFile(C.GoString(path))
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  composer, err := con.LookupComposer()
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  wf := sdk.Workflow{}
  err = yaml.Unmarshal(file, &wf)
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }
  
  err = composer.CreateWorkflow(C.GoString(name), &wf)
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  } else {
    return C.CString("Workflow created.")
  }
}

//export Composer_show
func Composer_show(name *C.char) *C.char {
  con := sdk.NewConnect(proxy_path)
  composer, err := con.LookupComposer()
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  depl, err := composer.Workflow(C.GoString(name))
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }
  
  d, err := yaml.Marshal(depl.Workflow)
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  return C.CString(string(d))
}

//export Composer_delete
func Composer_delete(name *C.char) *C.char {
  con := sdk.NewConnect(proxy_path)
  composer, err := con.LookupComposer()
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }
  
  err = composer.DeleteWorkflow(C.GoString(name))
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  } else {
    return C.CString("Workflow deleted.")
  }
}

//export Composer_config_show
func Composer_config_show() *C.char {
  con := sdk.NewConnect(proxy_path)
  comp, err := con.LookupComposer()
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  cfg, err := comp.GetConfig()
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  desc, err := json.MarshalIndent(cfg, "", "    ")
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }
  
  return C.CString(string(desc))
}

//export Composer_config_set
func Composer_config_set(path *C.char) *C.char {
  con := sdk.NewConnect(proxy_path)
  file, err := ioutil.ReadFile(C.GoString(path))
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  var cfg swagger.ComposerConfig
  err = json.Unmarshal(file, &cfg)
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  comp, err := con.LookupComposer()
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  }

  err = comp.SetConfig(&cfg)
  if err != nil {
    return C.CString("Fastscore Error --- " + err.Error())
  } else {
    return C.CString("Composer configuration set.")
  }
}