package main

import (
	"github.com/gnolang/gno/gno.land/pkg/gnoclient"
	rpcclient "github.com/gnolang/gno/tm2/pkg/bft/rpc/client"
)

// Example_readOnly demonstrates how to initialize a read-only gnoclient, which can only query.
func Example_readOnly() {
	remote := "127.0.0.1:26657"
	rpcClient, _ := rpcclient.NewHTTPClient(remote)

	client := gnoclient.Client{
		RPCClient: rpcClient,
	}
	res, _, _ := client.QEval("gno.land/r/sys/users", "ResolveName(\"leon000\"")
	println(res)
}
