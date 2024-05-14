package ex1

import (
	"gno.land/p/demo/te"

	"std"
)

func DeriveAddr() std.Address {
	realmAddr := std.DerivePkgAddr("gno.land/p/demo/ex1") // g1487zpvck3mg8e3vcsrlwv8ekwexrfwae77x7y0
	return realmAddr
}

func GetCallerStack() string {
	return te.GetCallerStack()
}

// Calling
// gnokey maketx call -pkgpath "gno.land/p/demo/ex1" -func "GetCallerStack" -gas-fee 1000000ugnot -gas-wanted 800000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// will give you
// ("Caller at 1: g1aq9ap83e0fx5quv3q9htlzcr7xqn7s38gn70tj Caller at 2: g1487zpvck3mg8e3vcsrlwv8ekwexrfwae77x7y0\n" string)
