package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
	  "encoding/json"
	  "strconv"
	  "strings"
    "github.com/opendatagroup/fastscore-sdk-go/sdk/swagger/models"
	  "io/ioutil"
)

//export Stream_show
func Stream_show(name *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	stream, err := m.Stream(C.GoString(name))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	desc, err := json.MarshalIndent(stream.Desc, "", "    ")
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	return C.CString(string(desc))
}

//export Stream_list
func Stream_list() *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	snames, err := m.List(sdk.AssetTypeStream)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  
  var res []string
	for _, s := range snames {
		res = append(res, s)
	}
  
	return C.CString(ArrayToString(res))
}

//export Stream_add
func Stream_add(name *C.char, path *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  
  var stream *sdk.Stream

  if strings.Contains(C.GoString(path), ":") {
    stream, err = sdk.ExpandStream(C.GoString(path))
    if err != nil {
		  return C.CString("Fastscore Error --- " + err.Error())
	  }
  } else {
    file, err := ioutil.ReadFile(C.GoString(path))
    if err != nil {
	  	return C.CString("Fastscore Error --- " + err.Error())
	  }

    var desc models.StreamDescriptor

    err = json.Unmarshal(file, &desc)
    if err != nil {
		  return C.CString("Fastscore Error --- " + err.Error())
	  }

    stream = &sdk.Stream{
    	Name:   C.GoString(name),
    	Desc:   desc,
    	Manage: m,
    }
  }

	code, err := m.SetStream(C.GoString(name), stream)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	if code == 0 {
    return C.CString("Stream added.")
	} else if code == 1 {
		return C.CString("Stream updated.")
	} else {
	  return C.CString("Fastscore error --- check stream update call.")
	}
}

//export Stream_remove
func Stream_remove(name *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	err = m.DeleteStream(C.GoString(name))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Stream removed.")
	}
}

//export Stream_attach
func Stream_attach(slot int, name *C.char, enginename *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	e, err := connect.GetEngine(C.GoString(enginename))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	streamname := C.GoString(name)
  var stream *sdk.Stream

  if strings.Contains(streamname, ":") {
    stream, err = sdk.ExpandStream(streamname)
   if err != nil {
		  return C.CString("Fastscore Error --- " + err.Error())
	  }
  } else {
    stream, err = m.Stream(streamname)
    if err != nil {
		  return C.CString("Fastscore Error --- " + err.Error())
	  }
  }

	_, err = e.AttachStream(stream, slot)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Stream attached to slot " + strconv.Itoa(slot) + ".")
	}
}

//export Stream_detach
func Stream_detach(slot int, enginename *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	e, err := connect.GetEngine(C.GoString(enginename))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	err = e.DetachStream(slot)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Stream detached from slot " + strconv.Itoa(slot) + ".")
	}
}

//export Stream_inspect
func Stream_inspect(name *C.char, enginename *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	e, err := connect.GetEngine(C.GoString(enginename))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	activestreams, err := e.ActiveStreams()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	var res []string
	for _, v := range activestreams {
		desc := (v.Desc).(map[string]interface{})
		transport := desc["Transport"]
		var transportType string
		switch transport.(type) {
		case map[string]interface{}:
			transportType = transport.(map[string]interface{})["Type"].(string)
			break
		case string:
			transportType = transport.(string)
			break
		default:
			return C.CString("Fastscore Error --- Unknown stream descriptor")
		}
		res = append(res, strconv.Itoa(v.Slot) + v.Name + transportType + strconv.FormatBool(v.EOF))
	}

	return C.CString(ArrayToString(res))
}

//export Stream_sample
func Stream_sample(name *C.char, enginename *C.char, count int) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	e, err := connect.GetEngine(C.GoString(enginename))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	streamname := C.GoString(name)
	n := 10
	if count > 0 {
	  n = count
	}

	stream, err := m.Stream(streamname)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	resp, err := stream.Sample(e, n)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  
  var res []string
	for i, v := range resp {
		res = append(res, strconv.Itoa(i + 1) + ": " + string(v))
	}

	return C.CString(ArrayToString(res))
}