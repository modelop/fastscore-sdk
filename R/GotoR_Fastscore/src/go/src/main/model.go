package main

import (
    "C"
    "io/ioutil"
    "strconv"
    "bufio"
    "os"
    "strings"
    "path/filepath"
    
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
)

//export Model_add
func Model_add(name *C.char, path *C.char) *C.char{
  file, err := ioutil.ReadFile(C.GoString(path))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  source := string(file)
  
  var mtype string
  mtype = guessModelType(C.GoString(path))
  
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  mm, err := con.LookupManage()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  model := sdk.Model{
			Name:   C.GoString(name),
			Source: source,
			MType:  mtype,
			Manage: mm,
	}
  
  code, err := model.Update(mm)
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  if code == 0 {
    return C.CString("Model added.")
	} else if code == 1 {
		return C.CString("Model updated.")
	} else {
	  return C.CString("Fastscore error --- check model update call.")
	}
}

//export Model_show
func Model_show(name *C.char) *C.char{
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  mm, err := con.LookupManage()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  model, err := mm.Model(C.GoString(name))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	return C.CString(model.Source)
}

//export Model_list
func Model_list() *C.char{
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  mm, err := con.LookupManage()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  models, err := mm.Models()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  
  var res []string
  for _, v := range models {
		atts := ""
		for i, a := range v.Attachments {
			atts += a.Name
			if i != len(v.Attachments)-1 {
				atts += ", "
			}
		}
		res = append(res, v.Name + " | " + string(v.MType) + " | atts: " + atts)
	}
  
	return C.CString(ArrayToString(res))
}

//export Model_remove
func Model_remove(name *C.char) *C.char{
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  mm, err := con.LookupManage()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  err = mm.DeleteModel(C.GoString(name))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Model removed.")
	}
}

//export Model_load
func Model_load(modelname *C.char, enginename *C.char) *C.char{
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  mm, err := con.LookupManage()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  eng, err := con.GetEngine(C.GoString(enginename))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  model, err := mm.Model(C.GoString(modelname))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  
  var attachmentOverrideList []*sdk.Attachment
  _, err = eng.LoadModel(sdk.EngineLoadModelArgs{
		Model:                  model,
		AttachmentOverrideList: attachmentOverrideList,
	})
	if err != nil{
	  return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Model loaded.")
	}
}
// TODO: OverrideList

// TODO: Model_unload

//export Model_inspect
func Model_inspect(enginename *C.char) *C.char{
  con := sdk.NewConnect(proxy_path, "", "", "", "")
  eng, err := con.GetEngine(C.GoString(enginename))
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  activemodel, err := eng.ActiveModel()
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
  atts := "none"
	if len(activemodel.Attachments) > 0 {
		atts = strings.Join(activemodel.Attachments[:], ",")
	}
	
  var res []string
  res = append(res, "Model: " + activemodel.Name + " | " +
                                activemodel.MType + " | " +
		                            activemodel.Snapshots + " | " +
		                            atts)

	for _, v := range activemodel.Slots {
		res = append(res, "Stream: slot" + strconv.Itoa(v.Slot) + " | " +
                                v.Action + " | recordsets:" +
		                            strconv.FormatBool(v.Recordsets))
	}	                            
	
	for i, v := range activemodel.Jets {
		res = append(res, "Jets#" + strconv.Itoa(i + 1) + " | PID:" +
                                strconv.Itoa(v.PID) + " | Sandbox:" +
		                            v.Sandbox)
	}
  return C.CString(ArrayToString(res))
}

//export Model_input
func Model_input(enginename *C.char, slot int) *C.char{
  con := sdk.NewConnect(proxy_path, "", "", "", "")
	eng, err := con.GetEngine(C.GoString(enginename))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	reader := bufio.NewReader(os.Stdin)
	for {
		data, _ := reader.ReadString('\n')
		data = strings.TrimSuffix(data, "\n")
		if len(data) == 0 {
			break
		}
		eng.Input(data, slot)
	}
	return C.CString("Input to " + eng.Name)
}

//export Model_output
func Model_output(enginename *C.char, slot int) *C.char{
  if slot == 0{
    slot = 1
  }
  con := sdk.NewConnect(proxy_path, "", "", "", "")
	eng, err := con.GetEngine(C.GoString(enginename))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	var res []string
	for {
		data, _ := eng.Output(slot)

		sdata := string(data)
		if sdata == "" {
			break
		}
		res = append(res, sdata)
	}
	return C.CString(ArrayToString(res))
}

//TODO: Model_interact

//export Model_scale
func Model_scale(enginename *C.char, scale int) *C.char{
	con := sdk.NewConnect(proxy_path, "", "", "", "")
	eng, err := con.GetEngine(C.GoString(enginename))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	return C.CString(eng.Scale(scale).Error())
}

func guessModelType(path string) string {
	ext := filepath.Ext(path)
	switch strings.ToLower(ext) {
	case ".py": // Python3 is the default now
		return "Python3"
	case ".py3":
		return "Python3"
	case ".py2":
		return "Python2"
	case ".r":
		return "R"
	case ".ipynb":
		return "Jupyter"
	case ".c":
		return "C"
	case ".pfa":
		return "PFA-json"
	case ".json":
		return "PFA-json"
	case ".yaml":
		return "PFA-yaml"
	case ".ppfa":
		return "PFA-pretty"
	case ".m":
		return "Octave"
	default:
		return "unknown"
	}
}