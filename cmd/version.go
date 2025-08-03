/*
Copyright © 2025 NAME HERE andriiyerzh@gmail.com
*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var appVersion string = "Version"

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version of kbot",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(appVersion)
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
