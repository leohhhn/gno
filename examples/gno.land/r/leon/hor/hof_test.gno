package hor

import (
	"std"
	"strings"
	"testing"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/testutils"
	"gno.land/p/demo/uassert"
	"gno.land/p/demo/urequire"
	"gno.land/p/moul/addrset"
)

const (
	rlmPath1 = "gno.land/r/gnoland/home"
	rlmPath2 = "gno.land/r/gnoland/test2"
	rlmPath3 = "gno.land/r/gnoland/test3"
	rlmPath4 = "gno.land/r/gnoland/test4"

	validTitle         = "valid title"
	invalidTitle       = "This title is very very very long, longer than 30 characters"
	validDesc          = "valid description"
	invalidDescription = "This description is very very very long, longer than 50 characters"
)

var (
	admin      = Ownable.Owner()
	adminRealm = std.NewUserRealm(admin)
	alice      = testutils.TestAddress("alice")
)

func TestRegister(t *testing.T) {
	//Test user realm register
	aliceRealm := std.NewUserRealm(alice)
	testing.SetRealm(aliceRealm)

	cross(Register)(validTitle, validDesc)
	uassert.False(t, itemExists(t, rlmPath1))

	// Test register while paused
	testing.SetRealm(adminRealm)
	testing.SetOriginCaller(adminRealm.Address())
	Pausable.Pause()

	// Set legitimate caller
	testing.SetRealm(std.NewCodeRealm(rlmPath1))
	cross(Register)(validTitle, validDesc)

	uassert.False(t, itemExists(t, rlmPath1))

	// Unpause
	testing.SetRealm(adminRealm)
	Pausable.Unpause()

	// Set legitimate caller
	testing.SetRealm(std.NewCodeRealm(rlmPath1))
	cross(Register)(validTitle, validDesc)

	// Find registered items
	uassert.True(t, itemExists(t, rlmPath1))

	// Test register with invalid title
	testing.SetRealm(std.NewCodeRealm(rlmPath2))
	cross(Register)(invalidTitle, validDesc)
	uassert.False(t, itemExists(t, rlmPath2))

	// Test register with invalid description
	testing.SetRealm(std.NewCodeRealm(rlmPath2))
	cross(Register)(validTitle, invalidDescription)
	uassert.False(t, itemExists(t, rlmPath2))
}

func TestUpvote(t *testing.T) {
	setupTest(t)

	testing.SetRealm(std.NewCodeRealm(rlmPath1))
	cross(Register)(validTitle, validDesc)

	raw, _ := exhibition.items.Get(rlmPath1)
	item := raw.(*Item)

	// 0 upvotes by default
	urequire.Equal(t, item.upvote.Size(), 0)

	testing.SetRealm(adminRealm)

	urequire.NotPanics(t, func() {
		Upvote(rlmPath1)
	})

	// Check both trees for 1 upvote
	uassert.Equal(t, item.upvote.Size(), 1)

	// Check double upvote
	uassert.PanicsWithMessage(t, ErrDoubleUpvote.Error(), func() {
		Upvote(rlmPath1)
	})
}

func TestDownvote(t *testing.T) {
	setupTest(t)

	testing.SetRealm(std.NewCodeRealm(rlmPath1))
	cross(Register)(validTitle, validDesc)

	raw, _ := exhibition.items.Get(rlmPath1)
	item := raw.(*Item)

	// 0 downvotes by default
	urequire.Equal(t, item.downvote.Size(), 0)

	userRealm := std.NewUserRealm(alice)
	testing.SetRealm(userRealm)

	urequire.NotPanics(t, func() {
		Downvote(rlmPath1)
	})

	// Check both trees for 1 upvote
	uassert.Equal(t, item.downvote.Size(), 1)

	// Check double downvote
	uassert.PanicsWithMessage(t, ErrDoubleDownvote.Error(), func() {
		Downvote(rlmPath1)
	})
}

func TestDelete(t *testing.T) {
	setupTest(t)

	testing.SetRealm(std.NewCodeRealm(rlmPath1))
	cross(Register)(validTitle, validDesc)

	userRealm := std.NewUserRealm(admin)
	testing.SetRealm(userRealm)
	testing.SetOriginCaller(admin)

	uassert.PanicsWithMessage(t, ErrNoSuchItem.Error(), func() {
		Delete("nonexistentpkgpath")
	})

	uassert.NotPanics(t, func() {
		Delete(rlmPath1)
	})

	uassert.False(t, exhibition.items.Has(rlmPath1))
}

func TestgetVoteSortKey(t *testing.T) {
	i := &Item{
		id:          1,
		title:       validTitle,
		description: validDesc,
		pkgpath:     rlmPath1,
		blockNum:    std.ChainHeight(),
		upvote:      &addrset.Set{},
		downvote:    &addrset.Set{},
	}

	i.upvote.Add(alice)

	generatedKey := getVoteSortKey(i.upvote.Size(), i.id)
	expectedKey := "0000000001:1"

	urequire.Equal(t, generatedKey, expectedKey)
}

func TestSortByUpvote(t *testing.T) {
	setupTest(t)

	// Add items
	testing.SetRealm(std.NewCodeRealm(rlmPath2))
	cross(Register)(validTitle, validDesc)

	testing.SkipHeights(10)
	testing.SetRealm(std.NewCodeRealm(rlmPath3))
	cross(Register)(validTitle, validDesc)

	testing.SkipHeights(10)
	testing.SetRealm(std.NewCodeRealm(rlmPath4))
	cross(Register)(validTitle, validDesc)

	user1 := testutils.TestAddress("user1")
	user2 := testutils.TestAddress("user2")
	user3 := testutils.TestAddress("user3")

	testing.SetOriginCaller(user1)
	testing.SetRealm(std.NewUserRealm(user1))
	Upvote(rlmPath2)
	Upvote(rlmPath3)
	Upvote(rlmPath4)

	testing.SetOriginCaller(user2)
	testing.SetRealm(std.NewUserRealm(user2))
	Upvote(rlmPath3)
	Upvote(rlmPath4)

	testing.SetOriginCaller(user3)
	testing.SetRealm(std.NewUserRealm(user3))
	Upvote(rlmPath4)
	Downvote(rlmPath3)

	render := exhibition.Render("?sort=upvotes", false)

	pos2 := strings.Index(render, strings.TrimPrefix(rlmPath2, "gno.land"))
	pos3 := strings.Index(render, strings.TrimPrefix(rlmPath3, "gno.land"))
	pos4 := strings.Index(render, strings.TrimPrefix(rlmPath4, "gno.land"))

	if pos4 > pos3 || pos4 > pos2 || pos3 > pos2 {
		t.Fatalf("expected different order")
	}
}

func TestSortByDownvote(t *testing.T) {
	setupTest(t)

	// Add items
	testing.SetRealm(std.NewCodeRealm(rlmPath2))
	cross(Register)(validTitle, validDesc)

	testing.SetRealm(std.NewCodeRealm(rlmPath3))
	cross(Register)(validTitle, validDesc)

	testing.SetRealm(std.NewCodeRealm(rlmPath4))
	cross(Register)(validTitle, validDesc)

	user1 := testutils.TestAddress("user1")
	user2 := testutils.TestAddress("user2")
	user3 := testutils.TestAddress("user3")

	testing.SetOriginCaller(user1)
	testing.SetRealm(std.NewUserRealm(user1))
	Downvote(rlmPath2)
	Downvote(rlmPath3)
	Downvote(rlmPath4)

	testing.SetOriginCaller(user2)
	testing.SetRealm(std.NewUserRealm(user2))
	Downvote(rlmPath3)
	Downvote(rlmPath4)

	testing.SetOriginCaller(user3)
	testing.SetRealm(std.NewUserRealm(user3))
	Downvote(rlmPath4)

	render := exhibition.Render("?sort=downvotes", false)

	pos2 := strings.Index(render, strings.TrimPrefix(rlmPath2, "gno.land"))
	pos3 := strings.Index(render, strings.TrimPrefix(rlmPath3, "gno.land"))
	pos4 := strings.Index(render, strings.TrimPrefix(rlmPath4, "gno.land"))

	if pos4 > pos3 || pos4 > pos2 || pos3 > pos2 {
		t.Fatalf("expected different order")
	}
}

func TestSortByCreation(t *testing.T) {
	setupTest(t)

	println(std.ChainHeight())

	// Add items
	testing.SetRealm(std.NewCodeRealm(rlmPath2))
	cross(Register)(validTitle, validDesc)
	testing.SkipHeights(10)

	println(std.ChainHeight())
	testing.SetRealm(std.NewCodeRealm(rlmPath3))
	cross(Register)(validTitle, validDesc)
	testing.SkipHeights(10)

	println(std.ChainHeight())

	testing.SetRealm(std.NewCodeRealm(rlmPath4))
	cross(Register)(validTitle, validDesc)

	render := exhibition.Render("?sort=creation", false)

	pos2 := strings.Index(render, strings.TrimPrefix(rlmPath2, "gno.land"))
	pos3 := strings.Index(render, strings.TrimPrefix(rlmPath3, "gno.land"))
	pos4 := strings.Index(render, strings.TrimPrefix(rlmPath4, "gno.land"))

	println(render)

	println(pos2, pos3, pos4)

	//if pos4 > pos3 || pos4 > pos2 || pos3 > pos2 {
	//	t.Fatalf("expected different order")
	//}
}

func setupTest(t *testing.T) {
	t.Helper()
	exhibition.items = avl.NewTree()
	exhibition.itemsSortedByUpvotes = avl.NewTree()
	exhibition.itemsSortedByDownvotes = avl.NewTree()
	exhibition.itemsSortedByCreation = avl.NewTree()
	exhibition.itemCounter = 0
}

func itemExists(t *testing.T, rlmPath string) bool {
	t.Helper()
	return exhibition.items.Has(rlmPath)
}
