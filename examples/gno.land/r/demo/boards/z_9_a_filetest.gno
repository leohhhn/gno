package main

// SEND: 1000000ugnot

import (
	"std"
	"testing"

	"gno.land/r/demo/boards"
	users "gno.land/r/gnoland/users/v1"
)

var dstBoard boards.BoardID

func init() {
	testing.SetRealm(std.NewUserRealm(std.Address("g1wymu47drhr0kuq2098m792lytgtj2nyx77yrsm"))) // so that CurrentRealm.Addr() matches OrigCaller
	users.Register(cross, "gnouser123")

	dstBoard = boards.CreateBoard(cross, "dst_board")
}

func main() {
	boards.CreateRepost(cross, 0, 0, "First Post in (title)", "Body of the first post. (body)", dstBoard)
}

// Error:
// invalid non-user call
