package main

import (
  "io/ioutil"
	"log"
	"path/filepath"
	"gopkg.in/yaml.v2"
	"github.com/mitchellh/go-homedir"
	"github.com/opendatagroup/fastscore-sdk-go/sdk"
)

// cannot export this function to R, since error is not a valid type to pass
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

	return sdk.NewConnect(cnf.ProxyPrefix, cnf.LdapAuthSecret, cnf.BasicAuthSecret, cnf.OAuth2Secret, cnf.SessionCookie)
}

func WriteConfigFile(cfg *sdk.Cfg) error {
	d, err := yaml.Marshal(cfg)
	if err != nil {
		return err
	}

	home, err := homedir.Dir()
	if err != nil {
		return err
	}

	err = ioutil.WriteFile(filepath.Join(home, ".fastscore"), d, 0644)

	return err
}