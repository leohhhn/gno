package upgradeb

import (
	"std"

	v1 "gno.land/r/x/manfred_upgrade_patterns/upgrade_b/v1"
)

const admin = "blahblah"

var (
	counter     int
	nextVersion string
)

func Inc(nb int) {
	if nextVersion != "" {
		panic("contract is locked, please use the new version at r/" + nextVersion)
	}
	counter += nb
}

func Get() int {
	return v1.Get() + counter
}

func SetNextVersion(addr string) {
	// assert CallTx call.
	std.AssertOriginCall()
	// assert admin.
	caller := std.CallerAt(2)
	if caller != std.OriginCaller() {
		panic("should not happen") // because std.AssertOriginCall().
	}
	if caller != admin {
		panic("unauthorized")
	}
	nextVersion = addr
}
