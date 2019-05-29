package main

import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
)

//export Get_Fleet
func Get_Fleet() *C.char{
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  r, err := con.Fleet()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  
  NH := make([]string, len(r))
  for i := 0; i < len(r); i++{
    NH[i] = r[i].Name + ": " + r[i].Health
  }
  res := ArrayToString(NH)
  return C.CString(res)
}