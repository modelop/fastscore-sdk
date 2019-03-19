package main

import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
)

//export Engine_inspect
func Engine_inspect(name *C.char) *C.char{
  con := sdk.NewConnect(proxy_path)
  eng, err := con.GetEngine(C.GoString(name))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  
  state, err := eng.State()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  res := eng.Name + " is " + state
  return C.CString(res)
}

//export Engine_pause
func Engine_pause(name *C.char) *C.char {
	con := sdk.NewConnect(proxy_path)
  eng, err := con.GetEngine(C.GoString(name))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	err = eng.Pause()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else{
	  return C.CString(eng.Name + " paused.")
	}
}

//export Engine_unpause
func Engine_unpause(name *C.char) *C.char {
	con := sdk.NewConnect(proxy_path)
  eng, err := con.GetEngine(C.GoString(name))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	err = eng.Unpause()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else{
	  return C.CString(eng.Name + " unpaused.")
	}
}

//export Engine_reset
func Engine_reset(name *C.char) *C.char {
  con := sdk.NewConnect(proxy_path)
  
  if C.GoString(name) == "all" {
	  emap, err := con.Engines()
		if err != nil {
			return C.CString("Fastscore Error --- " + err.Error())
		}

		for _, v := range emap {
			err = v.Reset()
			if err != nil {
				return C.CString("Fastscore Error --- " + err.Error())
			}
		}
		
		return C.CString("All engines reset.")
	}
  
  eng, err := con.GetEngine(C.GoString(name))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	err = eng.Reset()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else{
	  return C.CString(eng.Name + " reset.")
	}
}