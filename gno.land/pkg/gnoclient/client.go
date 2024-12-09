package gnoclient

import (
	rpcclient "github.com/gnolang/gno/tm2/pkg/bft/rpc/client"
	ctypes "github.com/gnolang/gno/tm2/pkg/bft/rpc/core/types"
	"github.com/gnolang/gno/tm2/pkg/crypto"
	"github.com/gnolang/gno/tm2/pkg/std"
)

type ReadOnlyProvider interface {
	QEval(pkgpath, expr string) string
	QRender(pkgpath, renderArg string) string
	QFile(pkgpath string) string
	QFunc(pkgpath string) string
}

type TransactionProvider interface {
	ReadOnlyProvider
	Call()
	AddPackage()
	Send()
	Run()
}

type ReadOnlyClient struct {
	ReadOnlyProvider // matches the interface
}

type SigningClient struct {
	ReadOnlyClient // matches the interfaces
}

func NewReadonlyClient(rpc) ReadOnlyClient       { return client{rpc} }
func NewSigningClient(rpc, signer) SigningClient { return client{rpc, signer} }

// Client provides an interface for interacting with the blockchain.
type Client struct {
	Signer   Signer // Signer for transaction authentication
	Provider        // always readonly
}

type Provider struct {
	RPCClient rpcclient.Client // RPC client for blockchain communication
}

var _ ReaderOnly = (*Provider)(nil)

type ReaderOnly interface {
	Query(cfg QueryCfg) (*ctypes.ResultABCIQuery, error)

	QueryAccount(addr crypto.Address) (*std.BaseAccount, *ctypes.ResultABCIQuery, error)
	QueryAppVersion() (string, *ctypes.ResultABCIQuery, error)
	QRender(pkgPath string, args string) (string, *ctypes.ResultABCIQuery, error)
	QEval(pkgPath string, expression string) (string, *ctypes.ResultABCIQuery, error)
	Block(height int64) (*ctypes.ResultBlock, error)
	BlockResult(height int64) (*ctypes.ResultBlockResults, error)
	LatestBlockHeight() (int64, error)

	// QFuncs
	// QFiles
	//
}

// validateSigner checks that the signer is correctly configured.
func (c *Client) validateSigner() error {
	if c.Signer == nil {
		return ErrMissingSigner
	}
	return nil
}

// validateRPCClient checks that the RPCClient is correctly configured.
func (c *Client) validateRPCClient() error {
	if c.RPCClient == nil {
		return ErrMissingRPCClient
	}
	return nil
}
