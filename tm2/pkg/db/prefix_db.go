package db

import (
	"bytes"
	"fmt"
	"sync"

	"github.com/gnolang/gno/tm2/pkg/colors"
)

// IteratePrefix is a convenience function for iterating over a key domain
// restricted by prefix.
func IteratePrefix(db DB, prefix []byte) Iterator {
	var start, end []byte
	if len(prefix) == 0 {
		start = nil
		end = nil
	} else {
		start = cp(prefix)
		end = cpIncr(prefix)
	}
	return db.Iterator(start, end)
}

/*
TODO: Make test, maybe rename.
// Like IteratePrefix but the iterator strips the prefix from the keys.
func IteratePrefixStripped(db DB, prefix []byte) Iterator {
	start, end := ...
	return newPrefixIterator(prefix, start, end, IteratePrefix(db, prefix))
}
*/

// ----------------------------------------
// prefixDB

type PrefixDB struct {
	mtx    sync.Mutex
	prefix []byte
	db     DB
}

// NewPrefixDB lets you namespace multiple DBs within a single DB.
func NewPrefixDB(db DB, prefix []byte) *PrefixDB {
	return &PrefixDB{
		prefix: prefix,
		db:     db,
	}
}

// Implements atomicSetDeleter.
func (pdb *PrefixDB) Mutex() *sync.Mutex {
	return &(pdb.mtx)
}

// Implements DB.
func (pdb *PrefixDB) Get(key []byte) []byte {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	pkey := pdb.prefixed(key)
	value := pdb.db.Get(pkey)
	return value
}

// Implements DB.
func (pdb *PrefixDB) Has(key []byte) bool {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	return pdb.db.Has(pdb.prefixed(key))
}

// Implements DB.
func (pdb *PrefixDB) Set(key []byte, value []byte) {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	pkey := pdb.prefixed(key)
	pdb.db.Set(pkey, value)
}

// Implements DB.
func (pdb *PrefixDB) SetSync(key []byte, value []byte) {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	pdb.db.SetSync(pdb.prefixed(key), value)
}

// Implements DB.
func (pdb *PrefixDB) Delete(key []byte) {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	pdb.db.Delete(pdb.prefixed(key))
}

// Implements DB.
func (pdb *PrefixDB) DeleteSync(key []byte) {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	pdb.db.DeleteSync(pdb.prefixed(key))
}

// Implements DB.
func (pdb *PrefixDB) Iterator(start, end []byte) Iterator {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	var pstart, pend []byte
	pstart = append(cp(pdb.prefix), start...)
	if end == nil {
		pend = cpIncr(pdb.prefix)
	} else {
		pend = append(cp(pdb.prefix), end...)
	}
	return newPrefixIterator(
		pdb.prefix,
		start,
		end,
		pdb.db.Iterator(
			pstart,
			pend,
		),
	)
}

// Implements DB.
func (pdb *PrefixDB) ReverseIterator(start, end []byte) Iterator {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	var pstart, pend []byte
	pstart = append(cp(pdb.prefix), start...)
	if end == nil {
		pend = cpIncr(pdb.prefix)
	} else {
		pend = append(cp(pdb.prefix), end...)
	}
	ritr := pdb.db.ReverseIterator(pstart, pend)
	return newPrefixIterator(
		pdb.prefix,
		start,
		end,
		ritr,
	)
}

// Implements DB.
// Panics if the underlying DB is not an
// atomicSetDeleter.
func (pdb *PrefixDB) NewBatch() Batch {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	return newPrefixBatch(pdb.prefix, pdb.db.NewBatch())
}

/* NOTE: Uncomment to use memBatch instead of prefixBatch
// Implements atomicSetDeleter.
func (pdb *PrefixDB) SetNoLock(key []byte, value []byte) {
	pdb.db.(atomicSetDeleter).SetNoLock(pdb.prefixed(key), value)
}

// Implements atomicSetDeleter.
func (pdb *PrefixDB) SetNoLockSync(key []byte, value []byte) {
	pdb.db.(atomicSetDeleter).SetNoLockSync(pdb.prefixed(key), value)
}

// Implements atomicSetDeleter.
func (pdb *PrefixDB) DeleteNoLock(key []byte) {
	pdb.db.(atomicSetDeleter).DeleteNoLock(pdb.prefixed(key))
}

// Implements atomicSetDeleter.
func (pdb *PrefixDB) DeleteNoLockSync(key []byte) {
	pdb.db.(atomicSetDeleter).DeleteNoLockSync(pdb.prefixed(key))
}
*/

// Implements DB.
func (pdb *PrefixDB) Close() error {
	pdb.mtx.Lock()
	defer pdb.mtx.Unlock()

	return pdb.db.Close()
}

// Implements DB.
func (pdb *PrefixDB) Print() {
	fmt.Println(colors.Blue("prefix ---------------------"))
	fmt.Printf("prefix: %v\n", colors.DefaultColoredBytes(pdb.prefix))
	pdb.db.Print()
	fmt.Println(colors.Blue("prefix --------------------- end"))
}

// Implements DB.
func (pdb *PrefixDB) Stats() map[string]string {
	stats := make(map[string]string)
	stats["prefixdb.prefix.string"] = string(pdb.prefix)
	stats["prefixdb.prefix.hex"] = fmt.Sprintf("%X", pdb.prefix)
	source := pdb.db.Stats()
	for key, value := range source {
		stats["prefixdb.source."+key] = value
	}
	return stats
}

func (pdb *PrefixDB) prefixed(key []byte) []byte {
	return append(cp(pdb.prefix), key...)
}

// ----------------------------------------
// prefixBatch

type prefixBatch struct {
	prefix []byte
	source Batch
}

func newPrefixBatch(prefix []byte, source Batch) prefixBatch {
	return prefixBatch{
		prefix: prefix,
		source: source,
	}
}

func (pb prefixBatch) Set(key, value []byte) {
	pkey := append(cp(pb.prefix), key...)
	pb.source.Set(pkey, value)
}

func (pb prefixBatch) Delete(key []byte) {
	pkey := append(cp(pb.prefix), key...)
	pb.source.Delete(pkey)
}

func (pb prefixBatch) Write() {
	pb.source.Write()
}

func (pb prefixBatch) WriteSync() {
	pb.source.WriteSync()
}

func (pb prefixBatch) Close() {
	pb.source.Close()
}

// ----------------------------------------
// prefixIterator

var _ Iterator = (*prefixIterator)(nil)

// Strips prefix while iterating from Iterator.
type prefixIterator struct {
	prefix []byte
	start  []byte
	end    []byte
	source Iterator
	valid  bool
}

func newPrefixIterator(prefix, start, end []byte, source Iterator) *prefixIterator {
	if !source.Valid() || !bytes.HasPrefix(source.Key(), prefix) {
		return &prefixIterator{
			prefix: prefix,
			start:  start,
			end:    end,
			source: source,
			valid:  false,
		}
	}
	return &prefixIterator{
		prefix: prefix,
		start:  start,
		end:    end,
		source: source,
		valid:  true,
	}
}

func (itr *prefixIterator) Domain() (start []byte, end []byte) {
	return itr.start, itr.end
}

func (itr *prefixIterator) Valid() bool {
	return itr.valid && itr.source.Valid()
}

func (itr *prefixIterator) Next() {
	if !itr.valid {
		panic("prefixIterator invalid, cannot call Next()")
	}
	itr.source.Next()
	if !itr.source.Valid() || !bytes.HasPrefix(itr.source.Key(), itr.prefix) {
		itr.valid = false
		return
	}
}

func (itr *prefixIterator) Key() (key []byte) {
	if !itr.valid {
		panic("prefixIterator invalid, cannot call Key()")
	}
	return stripPrefix(itr.source.Key(), itr.prefix)
}

func (itr *prefixIterator) Value() (value []byte) {
	if !itr.valid {
		panic("prefixIterator invalid, cannot call Value()")
	}
	return itr.source.Value()
}

func (itr *prefixIterator) Close() {
	itr.source.Close()
}

// ----------------------------------------

func stripPrefix(key []byte, prefix []byte) (stripped []byte) {
	if len(key) < len(prefix) {
		panic("should not happen")
	}
	if !bytes.Equal(key[:len(prefix)], prefix) {
		panic("should not happen")
	}
	return key[len(prefix):]
}
