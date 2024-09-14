package registry

import "github.com/gnolang/gno/examples/gno.land/p/demo/grc/grc20"

var tokens []grc20.Token

func Register(t grc20.Token) {
	tokens = append(tokens, t)
}
