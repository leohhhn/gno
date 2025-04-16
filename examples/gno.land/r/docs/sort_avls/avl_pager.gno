package avl_pager

import (
	"strconv"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/seqid"
	"gno.land/p/leon/sortedrender"
)

var (
	seqIDTree     = avl.NewTree()
	numericalTree = avl.NewTree()
	id            seqid.ID
)

func init() {
	for i := 0; i < 256; i++ {
		id := id.Next().String()

		seqIDTree.Set(id, "whatever"+strconv.Itoa(i))
		numericalTree.Set(strconv.Itoa(i), "whatever"+strconv.Itoa(i))
	}
}

func Render(path string) string {
	return sortedrender.NewTreeStore(
		[]string{"Alphabetical", "Numerical"},
		seqIDTree, numericalTree,
	).Render(path)
}
