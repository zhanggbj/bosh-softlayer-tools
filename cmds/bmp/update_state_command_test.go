package bmp_test

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	fakes "github.com/cloudfoundry-community/bosh-softlayer-tools/clients/fakes"
	cmds "github.com/cloudfoundry-community/bosh-softlayer-tools/cmds"
	bmp "github.com/cloudfoundry-community/bosh-softlayer-tools/cmds/bmp"
)

var _ = Describe("update-state command", func() {
	var (
		args    []string
		options cmds.Options
		cmd     cmds.Command

		fakeBmpClient *fakes.FakeBmpClient
	)

	BeforeEach(func() {
		args = []string{"bmp", "update-state"}
		options = cmds.Options{
			Verbose: false,
			Server:  "fake-server-id",
			State:   "bm.state.new",
		}

		fakeBmpClient = fakes.NewFakeBmpClient("fake-username", "fake-password", "http://fake.url.com", "fake-config-path")
		cmd = bmp.NewUpdateStateCommand(options, fakeBmpClient)
	})

	Describe("NewUpdateStateCommand", func() {
		It("create new UpdateStateCommand", func() {
			Expect(cmd).ToNot(BeNil())

			cmd2 := bmp.NewUpdateStateCommand(options, fakeBmpClient)
			Expect(cmd2).ToNot(BeNil())
			Expect(cmd2).To(Equal(cmd))
		})
	})

	Describe("#Name", func() {
		It("returns the name of a UpdateStateCommand", func() {
			Expect(cmd.Name()).To(Equal("update-state"))
		})
	})

	Describe("#Description", func() {
		It("returns the description of a UpdateStateCommand", func() {
			Expect(cmd.Description()).To(Equal(`Update the server state (\"bm.state.new\", \"bm.state.using\", \"bm.state.loading\", \"bm.state.failed\", \"bm.state.deleted\")`))
		})
	})

	Describe("#Usage", func() {
		It("returns the usage text of a UpdateStateCommand", func() {
			Expect(cmd.Usage()).To(Equal("bmp update-state --server <server-id> --state <state>"))
		})
	})

	Describe("#Options", func() {
		It("returns the options of a UpdateStateCommand", func() {
			Expect(cmds.EqualOptions(cmd.Options(), options)).To(BeTrue())
			Expect(cmd.Options().Server).ToNot(Equal(""))
			Expect(cmd.Options().Server).To(Equal("fake-server-id"))
			Expect(cmd.Options().State).ToNot(Equal(""))
			Expect(cmd.Options().State).To(Equal("bm.state.new"))
		})
	})

	Describe("#Validate", func() {
		It("validates a good UpdateStateCommand", func() {
			validate, err := cmd.Validate()
			Expect(validate).To(BeTrue())
			Expect(err).ToNot(HaveOccurred())
		})

		Context("when validating a bad UpdateStateCommand", func() {
			Context("when no server ID or state is passed", func() {
				BeforeEach(func() {
					options = cmds.Options{
						Verbose: false,
					}
				})

				It("fails validation with errors", func() {
					cmd = bmp.NewUpdateStateCommand(options, fakeBmpClient)
					validate, err := cmd.Validate()
					Expect(validate).To(BeFalse())
					Expect(err).To(HaveOccurred())
				})
			})

			Context("when server ID isn't passed", func() {
				BeforeEach(func() {
					options = cmds.Options{
						Verbose: false,
						Server:  "",
						State:   "bm.state.new",
					}
				})

				It("fails validation with errors", func() {
					cmd = bmp.NewUpdateStateCommand(options, fakeBmpClient)
					validate, err := cmd.Validate()
					Expect(validate).To(BeFalse())
					Expect(err).To(HaveOccurred())
				})
			})

			Context("when state isn't passed", func() {
				BeforeEach(func() {
					options = cmds.Options{
						Verbose:  false,
						Server:   "fake-server-id",
						Password: "bm.state.new",
					}
				})

				It("fails validation with errors", func() {
					cmd = bmp.NewUpdateStateCommand(options, fakeBmpClient)
					validate, err := cmd.Validate()
					Expect(validate).To(BeFalse())
					Expect(err).To(HaveOccurred())
				})
			})

			Context("when state isn't valid", func() {
				BeforeEach(func() {
					options = cmds.Options{
						Verbose:  false,
						Server:   "fake-server-id",
						Password: "fake-state",
					}
				})

				It("fails validation with errors", func() {
					cmd = bmp.NewUpdateStateCommand(options, fakeBmpClient)
					validate, err := cmd.Validate()
					Expect(validate).To(BeFalse())
					Expect(err).To(HaveOccurred())
				})
			})
		})
	})

	Describe("#Execute", func() {
		It("executes a good UpdateStateCommand", func() {
			rc, err := cmd.Execute(args)
			Expect(rc).To(Equal(1))
			Expect(err).To(HaveOccurred())
		})
	})
})
