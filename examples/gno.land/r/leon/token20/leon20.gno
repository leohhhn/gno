package leon20

import "github.com/gnolang/gno/examples/gno.land/p/demo/grc/grc20"

var leonToken grc20.Token

func init() {
	b := grc20.NewBanker("LeonToken", "LEON", 6)
	b.Token()
}

func Render() string {
	return "Hello world!"
}
