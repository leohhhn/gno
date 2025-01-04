package userreg

import (
	"testing"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/testutils"
	"gno.land/p/demo/uassert"
	"gno.land/p/demo/urequire"
)

var (
	alice     = "alice"
	aliceAddr = testutils.TestAddress(alice)

	bob     = "bob"
	bobAddr = testutils.TestAddress(bob)
)

func TestRegister(t *testing.T) {
	t.Run("valid", func(t *testing.T) {
		urequire.NoError(t, Register(alice, aliceAddr))

		res := ResolveName(alice)
		uassert.Equal(t, aliceAddr, res.addr)

		res = ResolveAddress(aliceAddr)
		uassert.Equal(t, alice, res.username)
	})

	//t.Run("addr_already_registered", func(t *testing.T) {
	//	cleanStore(t)
	//
	//	urequire.NoError(t, Register(alice, aliceAddr))
	//
	//	// Try registering again
	//	uassert.ErrorContains(t, Register(alice, aliceAddr), "address already registered")
	//})

	//t.Run("name_taken", func(t *testing.T) {
	//	cleanStore(t)
	//
	//	urequire.NoError(t, Register(alice, aliceAddr))
	//
	//	// Try registering alice's name with bob's address
	//	uassert.ErrorContains(t, Register(alice, bobAddr), "name already taken")
	//})

	//t.Run("address_deleted", func(t *testing.T) {
	//	cleanStore(t)
	//
	//	urequire.NoError(t, Register(alice, aliceAddr))
	//	urequire.NoError(t, Delete(alice))
	//
	//	// Try re-registering after deletion
	//	uassert.ErrorContains(t, Register(alice, aliceAddr), "user already deleted")
	//})
}

func TestRegisterAlias(t *testing.T) {
	t.Run("valid_direct_alias", func(t *testing.T) {
		cleanStore(t)

		urequire.NoError(t, Register(alice, aliceAddr))
		urequire

	})

}

func cleanStore(t *testing.T) {
	t.Helper()

	nameStore = avl.NewTree()
	addressStore = avl.NewTree()
}
