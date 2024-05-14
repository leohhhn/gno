package te

import (
	"gno.land/p/demo/ufmt"
	"std"
)

func DeriveAddr() std.Address {
	realmAddr := std.DerivePkgAddr("gno.land/p/demo/te") // g1aq9ap83e0fx5quv3q9htlzcr7xqn7s38gn70tj
	return realmAddr
}

func GetBalance() string {
	b := std.GetBanker(std.BankerTypeReadonly)
	return b.GetCoins("g1aq9ap83e0fx5quv3q9htlzcr7xqn7s38gn70tj").String()
}

// Run gnodev, then you can do:
// gnokey maketx send -to g1aq9ap83e0fx5quv3q9htlzcr7xqn7s38gn70tj --send 123ugnot --remote localhost:36657 --chainid dev --gas-fee 1000000ugnot -gas-wanted 2000000 --broadcast test1
// then, calling GetBalance:
// gnokey maketx call -pkgpath "gno.land/p/demo/te" -func "GetBalance" -gas-fee 1000000ugnot -gas-wanted 2000000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// Will output
// ("123ugnot" string)
// So, addresses are separate from packages themselves - they are on the TM2 level, as is the banker and coin balances

func GetRealmStack() (std.Realm, std.Realm) {
	return std.CurrentRealm(), std.PrevRealm()
}

// gnokey maketx call -pkgpath "gno.land/p/demo/te" -func "GetRealmStack" -gas-fee 1000000ugnot -gas-wanted 2000000  -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// will output
// (struct{("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5" std.Address),("" string)} std.Realm)
// (struct{("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5" std.Address),("" string)} std.Realm)
// So, packages themselves are not realms, but coincidentally an address can be derived from their pkgpath

func GetCallerStack() string {
	c1 := std.GetCallerAt(1)
	c2 := std.GetCallerAt(2)
	c3 := std.GetCallerAt(3)

	return ufmt.Sprintf("Caller at 1: %s Caller at 2: %s Caller at 3: %s", c1.String(), c2.String(), c3.String())
}

// gnokey maketx call -pkgpath "gno.land/p/demo/te" -func "GetCallerStack" -gas-fee 1000000ugnot -gas-wanted 2000000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// Will fail because there are only two addresses in the call stack:  frame not found
//
