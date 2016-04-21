package bmp

import (
	"errors"

	clients "github.com/cloudfoundry-community/bosh-softlayer-tools/clients"
	cmds "github.com/cloudfoundry-community/bosh-softlayer-tools/cmds"
	common "github.com/cloudfoundry-community/bosh-softlayer-tools/common"
)

type bmsCommand struct {
	args    []string
	options cmds.Options

	ui      common.UI
	printer common.Printer

	bmpClient clients.BmpClient
}

func NewBmsCommand(options cmds.Options, bmpClient clients.BmpClient) bmsCommand {
	consoleUi := common.NewConsoleUi()

	return bmsCommand{
		options:   options,
		ui:        consoleUi,
		printer:   common.NewDefaultPrinter(consoleUi, options.Verbose),
		bmpClient: bmpClient,
	}
}

func (cmd bmsCommand) Name() string {
	return "bms"
}

func (cmd bmsCommand) Description() string {
	return "List all bare metals"
}

func (cmd bmsCommand) Usage() string {
	return "bmp bms --deployment[-d] <deployment file>"
}

func (cmd bmsCommand) Options() cmds.Options {
	return cmd.options
}

func (cmd bmsCommand) Validate() (bool, error) {
	cmd.printer.Printf("Validating %s command: args: %#v, options: %#v", cmd.Name(), cmd.args, cmd.options)
	if cmd.options.Deployment == "" {
		return false, errors.New("please specify the deployment file with -d")
	}
	return true, nil
}

func (cmd bmsCommand) Execute(args []string) (int, error) {
	cmd.printer.Printf("Executing %s command: args: %#v, options: %#v", cmd.Name(), cmd.args, cmd.options)
	deploymentName := "test"
	bmsResponse, err := cmd.bmpClient.Bms(deploymentName)
	if err != nil {
		return bmsResponse.Status, err
	}

	if bmsResponse.Status != 200 {
		return bmsResponse.Status, err
	}

	return 0, nil
}
