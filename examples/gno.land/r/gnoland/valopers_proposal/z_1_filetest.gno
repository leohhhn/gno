// PKGPATH: gno.land/r/gnoland/valopers_proposal_test
// SEND: 100000000ugnot

package valopers_proposal_test

import (
	"std"
	"testing"

	"gno.land/p/demo/testutils"
	"gno.land/r/gnoland/valopers"
	"gno.land/r/gnoland/valopers_proposal"
	"gno.land/r/gov/dao"
	daoinit "gno.land/r/gov/dao/v3/init" // so that the govdao initializer is executed
)

var g1user = testutils.TestAddress("g1user") // g1vuch2um9wf047h6lta047h6lta047h6l2ewm6w

const (
	validMoniker     = "test-1"
	validDescription = "test-1's description"
	validAddress     = std.Address("g1sp8v98h2gadm5jggtzz9w5ksexqn68ympsd68h")
	validPubKey      = "gpub1pggj7ard9eg82cjtv4u52epjx56nzwgjyg9zqwpdwpd0f9fvqla089ndw5g9hcsufad77fml2vlu73fk8q8sh8v72cza5p"
)

func init() {
	testing.SetOriginCaller(g1user)
	daoinit.InitWithUsers(g1user)

	// Register a validator and add the proposal
	valopers.Register(cross, validMoniker, validDescription, validAddress, validPubKey)

	if err := revive(func() {
		pr := valopers_proposal.NewValidatorProposalRequest(cross, validAddress)
		dao.MustCreateProposal(cross, pr)
	}); err != nil {
		println("r: ", err)
	} else {
		println("OK")
	}
}

func main() {
	println(dao.Render(""))
}

// Output:
// OK
// # GovDAO Proposals
// ### [Prop #0 - Add valoper test-1 to the valset](/r/gov/dao:0)
// Author: g1vuch2um9wf047h6lta047h6lta047h6l2ewm6w
//
// Status: ACTIVE
//
// Tiers eligible to vote: T1, T2, T3
//
// ---
