// PKGPATH: gno.land/r/gnoland/valopers_proposal_test
// SEND: 20000000ugnot

package valopers_proposal_test

import (
	"std"
	"testing"

	"gno.land/p/demo/testutils"
	"gno.land/r/gnoland/valopers"
	"gno.land/r/gnoland/valopers_proposal"
	"gno.land/r/gov/dao"
	daoinit "gno.land/r/gov/dao/v3/init"
)

var (
	g1user = testutils.TestAddress("g1user")
)

const (
	validMoniker     = "test-1"
	validDescription = "test-1's description"
	validAddress     = std.Address("g1sp8v98h2gadm5jggtzz9w5ksexqn68ympsd68h")
	otherAddress     = std.Address("g1juz2yxmdsa6audkp6ep9vfv80c8p5u76e03vvh")
	validPubKey      = "gpub1pggj7ard9eg82cjtv4u52epjx56nzwgjyg9zqwpdwpd0f9fvqla089ndw5g9hcsufad77fml2vlu73fk8q8sh8v72cza5p"
)

func init() {
	testing.SetOriginCaller(g1user)
	daoinit.InitWithUsers(g1user)
}

func main() {
	testing.SetOriginCaller(g1user)
	// Register a validator
	valopers.Register(cross, validMoniker, validDescription, validAddress, validPubKey)
	// Try to make a proposal for a non-existing validator

	if err := revive(func() {
		pr := valopers_proposal.NewValidatorProposalRequest(cross, otherAddress)
		dao.MustCreateProposal(cross, pr)
	}); err != nil {
		println("r: ", err)
	}
}

// Output:
// r:  valoper does not exist
