package main
import (
    "C"
    "github.com/opendatagroup/fastscore-sdk-go/sdk"
    "encoding/json"
    "strings"
    "github.com/opendatagroup/fastscore-sdk-go/sdk/swagger"
    "strconv"
	  "io/ioutil"
)

//export Sensor_show
func Sensor_show(name *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path)
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	sensorname := C.GoString(name)
	sensor, err := m.Sensor(sensorname)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	desc, err := json.MarshalIndent(sensor.Desc, "", "    ")
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	return(C.CString(string(desc)))
}

//export Sensor_list
func Sensor_list() *C.char {
  connect := sdk.NewConnect(proxy_path)
	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	snames, err := m.List(sdk.AssetTypeSensor)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}
	
	var res []string
	for _, s := range snames {
		res = append(res, s)
	}
	
	return C.CString(ArrayToString(res))
}

//export Sensor_add
func Sensor_add(name *C.char, path *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path)
	file, err := ioutil.ReadFile(C.GoString(path))
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	var desc swagger.SensorDescriptor

	err = json.Unmarshal(file, &desc)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	m, err := connect.LookupManage()
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	sensor := sdk.Sensor{
		Name:   C.GoString(name),
		Desc:   desc,
		Manage: m,
	}

	code, err := m.SetSensor(C.GoString(name), &sensor)
	if err != nil {
		return C.CString("Fastscore Error --- " + err.Error())
	}

	if code == 0 {
			return C.CString("Sensor added.")
		} else if code == 1 {
			return C.CString("Sensor updated.")
		} else {
		  return C.CString("Fastscore Error --- check sensor update call.")
		}
}

//export Sensor_remove
func Sensor_remove(name *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path)
  m, err := connect.LookupManage()
  if err != nil {
      return C.CString("Fastscore Error --- " + err.Error())
  }
  err = m.DeleteSensor(C.GoString(name))
  if err != nil {
      return C.CString("Fastscore Error --- " + err.Error())
  } else {
    return C.CString("Sensor removed.")
  }
}

//export Sensor_install
func Sensor_install(name *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path)
  m, err := connect.LookupManage()
  if err != nil {
      return C.CString("Fastscore Error --- " + err.Error())
  }

  sensor, err := m.Sensor(C.GoString(name))
  if err != nil {
      return C.CString("Fastscore Error --- " + err.Error())
  }

  config, _ := GetCfg()
  instance := config.TargetName

  if strings.HasPrefix(instance, "engin"){
    e, err := connect.LookupEngine(config)
    if err != nil {
      return C.CString("Fastscore Error --- " + err.Error())
    }
    if e == nil {
      return C.CString("Please try function 'Use'.")
    }    		
    err = e.InstallSensor(sensor.Desc, e.Name)
    if err != nil {
      return C.CString("Fastscore Error --- " + err.Error())
    } else {
      return C.CString("Sensor installed to " + e.Name)
    }
  } else if strings.HasPrefix(instance, "model"){
    err = m.InstallSensor(sensor.Desc, m.Name)
    if err != nil {
      return C.CString("Fastscore Error --- " + err.Error())
    } else {
      return C.CString("Sensor installed to " + m.Name)
    }  
  } else{
    return C.CString("Please try function 'Use'.")
  }
}

//export Sensor_uninstall
func Sensor_uninstall(name *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path)
  x, err := strconv.ParseInt(C.GoString(name), 10, 8)
  if err != nil{
  	return C.CString("Fastscore Error --- " + err.Error())
  }

  tapid := int32(x)
  config, _ := GetCfg()
  instance := config.TargetName

  if strings.HasPrefix(instance, "engin"){
    e, err := connect.LookupEngine(config)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }
    active_sensor_list, err := e.GetActiveSensorList(e.Name)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }

    if containsTapId(active_sensor_list, tapid) == false {
      return C.CString("Fastscore Error --- Invalid tapid. Not present (tapid).")
    }

    err = e.UninstallSensor(tapid)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }

    return C.CString("Sensor uninstalled: " + string(tapid))

  } else if strings.HasPrefix(instance, "model"){
    m, err := connect.LookupManage()
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }

    active_sensor_list, err := m.GetActiveSensorList(m.Name)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }

    if containsTapId(active_sensor_list, tapid) == false {
      return C.CString("Fastscore Error --- Invalid tapid. Not present: (tapid)")
    }

    err = m.UninstallSensor(tapid)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }
    return C.CString("Sensor uninstalled: " + string(tapid))
  } else {
    return C.CString("Please try function 'Use'.")
  }
}

//export Sensor_points
func Sensor_points() *C.char{
  connect := sdk.NewConnect(proxy_path)
  config, _ := GetCfg()
  instance := config.TargetName

  if strings.HasPrefix(instance, "engin"){
    e, err := connect.LookupEngine(config)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }
    points, err := e.GetActiveSensorPoints(e.Name)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }

    return C.CString(ArrayToString(points))

  } else if strings.HasPrefix(instance, "model"){
    m, err := connect.LookupManage()
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }
    points, err := m.GetActiveSensorPoints(m.Name)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }

    return C.CString(ArrayToString(points))
  } else {
    return C.CString("Please try function 'Use'.")
  }
}

//export Sensor_inspect
func Sensor_inspect(name *C.char) *C.char {
  connect := sdk.NewConnect(proxy_path)
  x, err := strconv.ParseInt(C.GoString(name), 10, 8)
  if err != nil{
  	return C.CString("Fastscore Error --- " + err.Error())
  }

  tapid := int32(x)
  config, _ := GetCfg()
  instance := config.TargetName
  if strings.HasPrefix(instance, "engin"){
    e, err := connect.LookupEngine(config)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }
    active_sensor_list, err := e.GetActiveSensorList(e.Name)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }

    if containsTapId(active_sensor_list, tapid) == false {
      return C.CString("Fastscore Error --- Sensor not found. Check tapid.")
    }

    return C.CString("Sensor id " + string(tapid) + 
                    " is attached to" + active_sensor_list[tapid] + 
                    "at " + instance + ".")

  } else if strings.HasPrefix(instance, "model"){
    m, err := connect.LookupManage()
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }
    active_sensor_list, err := m.GetActiveSensorList(m.Name)
    if err != nil{
  	  return C.CString("Fastscore Error --- " + err.Error())
    }
    if containsTapId(active_sensor_list, tapid) == false {
      return C.CString("Fastscore Error --- Invalid tapid. Not present: (tapid).")
    }

    return C.CString("Sensor id " + string(tapid) + 
                    " is attached to" + active_sensor_list[tapid] + 
                    "at " + instance + ".")
  } else{
    return C.CString("Please try function 'Use'.")
  }
}

func containsTapId(m map[int32]string, tapid int32) bool {
    if _, ok := m[tapid]; ok {
    	return true
    }
    return false
}