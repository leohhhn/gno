package sending_gnot

import (
	"github.com/gnolang/gno/gnovm/stdlibs/std"
	"gno.land/p/moul/md"
)

func Render(_ string) string {
	out := "# Sending GNOT\n\n"
	out += `Here is how you send GNOT (or any other native coin), in Gno.` + "\n"

	out += md.CodeBlock(`package myrealm

import "std"

func SendGnot(to std.Address, amt int64) {
	banker := std.GetBanker(std.BankerTypeRealmSend)
	banker.SendCoins(std.CurrentRealm().Addr(), to, std.NewCoins(std.NewCoin("ugnot", amt))
}
`)

	return out
}

// SendGnot sends `amt` of GNOT from this realm to the `to` address
func SendGnot(to std.Address, amt int64) {
	banker := std.GetBanker(std.BankerTypeRealmSend)
	banker.SendCoins(std.CurrentRealm().Addr(), to, std.NewCoins(std.NewCoin("ugnot", amt)))
}
