package grc20

import (
	"github.com/gnolang/gno/examples/gno.land/p/demo/grc/grc20"
)

var bank *grc20.Banker = grc20.NewBanker("Gno Live Coding #3 Token", "LCS3", 6)
var Token grc20.Token = bank.Token()

func init() {
	_ = bank.Mint("g125em6arxsnj49vx35f0n0z34putv5ty3376fg5", 10000000000000)
}

func Render(_ string) string {
	return bank.RenderHome()
}
