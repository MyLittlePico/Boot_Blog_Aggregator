package config

import (
	"fmt"
	"os"
	"encoding/json"
)

const configFileName = ".gatorconfig.json"

type Config struct{
	DbURL string `json:"db_url"`
	CurrentUserName string `json:"current_user_name"`
}

func Read() (Config, error){
	path, err := getConfigFilePath()
	if err != nil{
		return Config{}, fmt.Errorf("Getting file path failed: %w\n", err)
	}

	data, err := os.ReadFile(path)
	if err != nil{
		return Config{}, fmt.Errorf("Reading file failed: %w\n", err)
	}
	var conf Config
	err = json.Unmarshal(data, &conf)
	if err != nil{
		return Config{}, fmt.Errorf("Unmarshaling data failed: %w\n", err)
	}
	return conf, nil

}

func (c *Config) SetUser(user string) error{
	c.CurrentUserName = user
	err := write(*c)
	return err
}


func write(cfg Config) error {
	path, err := getConfigFilePath()
	if err != nil{
		return fmt.Errorf("Getting file path failed: %w\n", err)
	}

	data, err := json.Marshal(cfg)
	if err != nil{
		return fmt.Errorf("Marshaling data failed: %w\n", err)
	}

	err = os.WriteFile(path, data, 0644)
	if err != nil{
		return fmt.Errorf("Writing file failed: %w\n", err)
	}
	return nil
}


func getConfigFilePath() (string, error) {
	root, err := os.UserHomeDir()
	if err != nil{
		return "", err
	}
	return (root +"/"+ configFileName), nil
}