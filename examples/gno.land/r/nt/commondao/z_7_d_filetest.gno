package main

import (
	"std"
	"testing"

	"gno.land/r/nt/commondao"
)

const (
	owner = std.Address("g16jpf0puufcpcjkph5nxueec8etpcldz7zwgydq") // @devx
	user  = std.Address("g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5") // @test1
)

var parentID uint64

func init() {
	// Invite a user to be able to start creating DAOs
	testing.SetRealm(std.NewUserRealm(owner))
	commondao.Invite(cross, user)

	// The origin must be the invited user
	testing.SetRealm(std.NewUserRealm(user))

	// Create the root DAO
	testing.SetRealm(std.NewCodeRealm("gno.land/r/nt/commondao"))
	parentDAO := commondao.New("Parent DAO", commondao.AllowChildren(false)) // Disallow SubDAOs
	parentID = parentDAO.ID()
}

func main() {
	testing.SetRealm(std.NewCodeRealm("gno.land/r/nt/commondao"))

	commondao.NewSubDAO("Foo", parentID)
}

// Error:
// SubDAO support is not enabled
