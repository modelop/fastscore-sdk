package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "strings"
)

//export Run
func Run(enginename *C.char, modelname *C.char, stream_name0 *C.char, stream_name1 *C.char) *C.char {
  streamname0 := C.GoString(stream_name0)
  streamname1 := C.GoString(stream_name1)
  
  con := sdk.NewConnect(proxy_path)
  eng, err := con.GetEngine(C.GoString(enginename))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	mm, err := con.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

  model, err := mm.Model(C.GoString(modelname))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  var stream0 *sdk.Stream

  if strings.Contains(streamname0, ":") {
    stream0, err = sdk.ExpandStream(streamname0)
    if err != nil {
	    return C.CString("Fastscore Error --- " + err.Error())
    }
  } else {
    stream0, err = mm.Stream(streamname0)
    if err != nil {
		    return C.CString("Fastscore Error --- " + err.Error())
	  }
  }

  var stream1 *sdk.Stream

  if strings.Contains(streamname1, ":") {
    stream1, err = sdk.ExpandStream(streamname1)
    if err != nil {
		  return C.CString("Fastscore Error --- " + err.Error())
	  }
  } else {
    stream1, err = mm.Stream(streamname1)
    if err != nil {
		  return C.CString("Fastscore Error --- " + err.Error())
	  }
  }


  _, err = eng.LoadModel(sdk.EngineLoadModelArgs{
      Model: model,
  })

  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

  err = eng.AttachStream(stream1, 1)
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

  err = eng.AttachStream(stream0, 0)
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

  return C.CString("Model " + C.GoString(modelname) + " deployed.")
}