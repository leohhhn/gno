package main

// SEND: 1000000ugnot

import (
	"std"
	"strconv"
	"testing"

	"gno.land/r/demo/boards"
	users "gno.land/r/gnoland/users/v1"
)

var (
	bid boards.BoardID
	pid boards.PostID
	rid boards.PostID
)

func init() {
	testing.SetRealm(std.NewUserRealm(std.Address("g1wymu47drhr0kuq2098m792lytgtj2nyx77yrsm"))) // so that CurrentRealm.Addr() matches OrigCaller
	users.Register(cross, "gnouser123")

	bid = boards.CreateBoard(cross, "test_board")
	boards.CreateThread(cross, bid, "First Post (title)", "Body of the first post. (body)")
	pid = boards.CreateThread(cross, bid, "Second Post (title)", "Body of the second post. (body)")
	rid = boards.CreateReply(cross, bid, pid, pid, "Reply of the second post")
}

func main() {
	testing.SetRealm(std.NewUserRealm(std.Address("g1wymu47drhr0kuq2098m792lytgtj2nyx77yrsm")))
	boards.CreateReply(cross, bid, pid, pid, "Second reply of the second post\n")
	boards.CreateReply(cross, bid, pid, rid, "First reply of the first reply\n")
	println(boards.Render("test_board/" + strconv.Itoa(int(pid))))
}

// Output:
// # Second Post (title)
//
// Body of the second post. (body)
// \- [@gnouser123](/u/gnouser123), [2009-02-13 11:31pm (UTC)](/r/demo/boards:test_board/2) \[[reply](/r/demo/boards$help&func=CreateReply&bid=1&postid=2&threadid=2)] \[[repost](/r/demo/boards$help&func=CreateRepost&bid=1&postid=2)] \[[x](/r/demo/boards$help&func=DeletePost&bid=1&postid=2&threadid=2)]
//
// > Reply of the second post
// > \- [@gnouser123](/u/gnouser123), [2009-02-13 11:31pm (UTC)](/r/demo/boards:test_board/2/3) \[[reply](/r/demo/boards$help&func=CreateReply&bid=1&postid=3&threadid=2)] \[[x](/r/demo/boards$help&func=DeletePost&bid=1&postid=3&threadid=2)]
// >
// > > First reply of the first reply
// > >
// > > \- [@gnouser123](/u/gnouser123), [2009-02-13 11:31pm (UTC)](/r/demo/boards:test_board/2/5) \[[reply](/r/demo/boards$help&func=CreateReply&bid=1&postid=5&threadid=2)] \[[x](/r/demo/boards$help&func=DeletePost&bid=1&postid=5&threadid=2)]
//
// > Second reply of the second post
// >
// > \- [@gnouser123](/u/gnouser123), [2009-02-13 11:31pm (UTC)](/r/demo/boards:test_board/2/4) \[[reply](/r/demo/boards$help&func=CreateReply&bid=1&postid=4&threadid=2)] \[[x](/r/demo/boards$help&func=DeletePost&bid=1&postid=4&threadid=2)]
//
