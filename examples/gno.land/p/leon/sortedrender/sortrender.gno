package sortedrender

import (
	"net/url"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/avl/pager"
	"gno.land/p/demo/avl/rotree"
)

type TreeStore struct { // XXX its a forest
	pageSize int
	keys     map[string]bool
	tree     *avl.Tree // sort key > matching tree
}

func NewTreeStore(pageSize int, sortKeys []string, trees ...*avl.Tree) *TreeStore {
	if len(sortKeys) != len(trees) {
		panic("need to pass in pairs of matching keys and trees")
	}

	tree := avl.NewTree()
	for i, key := range sortKeys {
		tree.Set(key, trees[i])
	}

	return &TreeStore{
		tree: tree,
	}
}

func (t TreeStore) Render(path string) string {
	out := ""

	values, err := url.ParseQuery(path)
	if err != nil {
		return err.Error()
	}

	sortKey := values.Get("sort")

	if len(sortKey) != 1 {
		return "must provide only 1 sort key"
	}

	dataTree, ok := t.tree.Get(sortKey)
	if !ok {
		panic("tree matching key not found")
	}

	tree := rotree.Wrap(dataTree, nil)
	// gets the tree
	page := pager.NewPager(tree, t.pageSize, true).MustGetPageByPath(path)

	for _, item := range page.Items {
		out += item.Key
	}

	return out
}
