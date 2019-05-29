package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "os"
	  "path/filepath"
    "strconv"
)

//export Attachment_upload
func Attachment_upload(mname *C.char, aname *C.char, apath *C.char) *C.char {
	model_name := C.GoString(mname)
	att_name := C.GoString(aname)
	att_path := C.GoString(apath)
	
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()  // lookup model manage
	model, err := m.Model(model_name)  // lookup model

	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	atype := guessAttachmentType(att_path)  // look up attachment type
	datasize, err := guessDataSize(att_path)  // look up attachment size

	if atype == "unknown" {
		return C.CString("Fastscore attachment can only accept .tgz, .zip, .tar.gz.")
	}
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	att := sdk.Attachment{
		Name:         att_name,
		Atype:        atype,
		Datafilepath: att_path,
		Datasize:     datasize,
		Model:        model,
	}
  
  // update model attachements
	model.Attachments = append(model.Attachments, &att)


	code, err := att.Upload()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	if code == 0 {
    return C.CString("Attachment added.")
	} else if code == 1 {
		return C.CString("Attachment updated.")
	} else {
	  return C.CString("Fastscore error --- check attachment update call.")
	}

}

//export Attachment_download
func Attachment_download(mname *C.char, aname *C.char, path *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	model_name := C.GoString(mname)
	att_name := C.GoString(aname)
	att_path := C.GoString(path)
  
  // download attachment
	err = m.DownloadAttachment(model_name, att_name, att_path)
  if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Attachment downloaded.")
	}
}

//export Attachment_list
func Attachment_list(modelname *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	model_name := C.GoString(modelname)

	attnames, err := m.ListAttachments(model_name)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
  
  // cannot pass double array, use ArrayToString
  var res []string
  for _, v := range attnames {
    a, err := m.Attachment(model_name, v)
    if err != nil {
		  return C.CString("Fastscore Error --- " + err.Error())
	  }
    res = append(res, a.Name + " | " +  a.Atype + " | " + strconv.Itoa(a.Datasize))
  }

	return C.CString(ArrayToString(res))
}

//export Attachment_remove
func Attachment_remove(mname *C.char, aname *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path, "", "", "", "")
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	model_name := C.GoString(mname)
	att_name := C.GoString(aname)
  
  // delete attachment
	err = m.DeleteAttachment(model_name, att_name)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	} else {
	  return C.CString("Attachment deleted.")
	}
}

func guessDataSize(file_to_upload string) (int, error) {

	file, err := os.Open(file_to_upload)

	if err != nil {
		return -1, err
	}

	defer file.Close()
	stat, err := file.Stat()

	datasize := int(stat.Size())

	return datasize, nil
}

func guessAttachmentType(path string) string {
	ext := filepath.Ext(path)
	switch ext {
	case ".zip":
		return "zip"
	case ".gz": // .tar.gz
		return "tgz"
	case ".tgz":
		return "tgz"
	default:
		return "unknown"
	}
}