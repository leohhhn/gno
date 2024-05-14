package terealm

import (
	"gno.land/p/demo/ex1"
	"gno.land/p/demo/te"
	"std"
)

func DeriveAddr() std.Address {
	realmAddr := std.DerivePkgAddr("gno.land/r/demo/terealm") // g1ga9l7tmghygtj38knwhx0qzrlwcguggyhkqsl8
	return realmAddr
}

func GetTeRealmStack() (std.Realm, std.Realm) {
	return te.GetRealmStack()
}

// gnokey maketx call -pkgpath "gno.land/r/demo/terealm" -func "GetTeRealmStack" -gas-fee 1000000ugnot -gas-wanted 800000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// (struct{("g1ga9l7tmghygtj38knwhx0qzrlwcguggyhkqsl8" std.Address),("gno.land/r/demo/terealm" string)} std.Realm)
// (struct{("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5" std.Address),("" string)} std.Realm)

func GetTeCallerStack() string {
	return te.GetCallerStack()
}

// gnokey maketx call -pkgpath "gno.land/r/demo/terealm" -func "GetTeCallerStack" -gas-fee 1000000ugnot -gas-wanted 800000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// Caller at 1: g1aq9ap83e0fx5quv3q9htlzcr7xqn7s38gn70tj > package te
// Caller at 2: g1ga9l7tmghygtj38knwhx0qzrlwcguggyhkqsl8 > terealm
// Caller at 3: g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5 > test1

func GetExCallerStack() string {
	return ex1.GetTeCallerStack()
}

// gnokey maketx call -pkgpath "gno.land/r/demo/terealm" -func "GetExCallerStack" -gas-fee 1000000ugnot -gas-wanted 800000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// Caller at 1: g1aq9ap83e0fx5quv3q9htlzcr7xqn7s38gn70tj
// Caller at 2: g1487zpvck3mg8e3vcsrlwv8ekwexrfwae77x7y0
// Caller at 3: g1ga9l7tmghygtj38knwhx0qzrlwcguggyhkqsl8

func GetExRealmStack() (std.Realm, std.Realm) {
	return ex1.GetTeRealmStack()
}

// gnokey maketx call -pkgpath "gno.land/r/demo/terealm" -func "GetExRealmStack" -gas-fee 1000000ugnot -gas-wanted 800000 -broadcast -chainid "dev" -remote "tcp://127.0.0.1:36657" test1
// (struct{("g1ga9l7tmghygtj38knwhx0qzrlwcguggyhkqsl8" std.Address),("gno.land/r/demo/terealm" string)} std.Realm)
// (struct{("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5" std.Address),("" string)} std.Realm)
