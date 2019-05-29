package main

import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "encoding/json"
    "io/ioutil"
)

//export Schema_list
func Schema_list() *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	r, err := m.List(sdk.AssetTypeSchema)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

  return C.CString(ArrayToString(r))
}

//export Schema_show
func Schema_show(name *C.char) *C.char {
	connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	schema, err := m.Schema(C.GoString(name))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	source, err := json.MarshalIndent(schema.Source, "", "    ")
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	return(C.CString(string(source)))
}

//export Schema_add
func Schema_add(name *C.char, path *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	file, err := ioutil.ReadFile(C.GoString(path))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	var source interface{}

	err = json.Unmarshal(file, &source)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	schema := sdk.Schema{
		Name:   C.GoString(name),
		Source: source,
		Manage: m,
	}

	code, err := m.SetSchema(C.GoString(name), &schema)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	if code == 0 {
    return C.CString("Schema added.")
	} else if code == 1 {
		return C.CString("Schema updated.")
	} else {
	  return C.CString("Fastscore error --- check schema update call.")
	}
}

//export Schema_remove
func Schema_remove(name *C.char) *C.char {
	connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	err = m.DeleteSchema(C.GoString(name))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Schema removed.")
	}
}

// TODO Schema_infer