package clients

type BmpClient interface {
	ConfigPath() string

	Info() (InfoResponse, error)
	SlPackages() (SlPackagesResponse, error)
	Bms(deploymentName string) (BmsResponse, error)
	Stemcells() (StemcellsResponse, error)
	SlPackageOptions(packageId string) (SlPackageOptionsResponse, error)
	Tasks(latest int) (TasksResponse, error)
	TaskOutput(taskId int, level string) (TaskOutputResponse, error)
	UpdateStatus(serverId string, status string) (UpdateStatusResponse, error)
	Login(username string, password string) (LoginResponse, error)
	CreateBaremetal(createBaremetalInfo CreateBaremetalInfo) (CreateBaremetalResponse, error)
}
