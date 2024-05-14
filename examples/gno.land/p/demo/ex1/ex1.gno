package ex1

import (
	"gno.land/p/demo/te"

	"std"
)

func DeriveAddr() std.Address {
	realmAddr := std.DerivePkgAddr("gno.land/p/demo/ex1") // g1487zpvck3mg8e3vcsrlwv8ekwexrfwae77x7y0
	return realmAddr
}

func GetTeRealmStack() (std.Realm, std.Realm) {
	return te.GetRealmStack()
}

// gnokey maketx call -pkgpath "gno.land/p/demo/ex1" -func "GetTeRealmStack" -gas-fee 1000000ugnot -gas-wanted 800000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// Will give you
// (struct{("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5" std.Address),("" string)} std.Realm) > test1
// (struct{("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5" std.Address),("" string)} std.Realm) > test1

func GetTeCallerStack() string {
	return te.GetCallerStack()
}

// Calling
// gnokey maketx call -pkgpath "gno.land/p/demo/ex1" -func "GetTeCallerStack" -gas-fee 1000000ugnot -gas-wanted 800000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// will give you
//
// Caller at 1: g1aq9ap83e0fx5quv3q9htlzcr7xqn7s38gn70tj > package te
// Caller at 2: g1487zpvck3mg8e3vcsrlwv8ekwexrfwae77x7y0 > package ex1
// Caller at 3: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 > test1 address
