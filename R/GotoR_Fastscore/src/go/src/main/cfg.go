package main

import (
	"io/ioutil"
	"log"
	"path/filepath"
	"gopkg.in/yaml.v2"
	"github.com/mitchellh/go-homedir"
	"github.com/opendatagroup/fastscore-sdk-go/sdk"
)

func GetCfg() (*sdk.Cfg, error) {
	c := sdk.Cfg{}

	home, err := homedir.Dir()
	if err != nil {
		return nil, err
	}
	yamlFile, err := ioutil.ReadFile(filepath.Join(home, ".fastscore"))
	if err != nil {
		return nil, err
	}

	err = yaml.Unmarshal(yamlFile, &c)
	return &c, err
}

func getConnect(cnf *sdk.Cfg, cfgerr error) *sdk.Connect {
	if cfgerr != nil {
		log.Fatal("ERROR: No FastScore connection found. Run fastscore connect <proxy-url>")
	}

	return sdk.NewConnect(cnf.ProxyPrefix)
}
