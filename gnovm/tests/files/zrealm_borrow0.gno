// PKGPATH: gno.land/r/borrow_test
package borrow_test

import (
	"fmt"
	"std"

	"gno.land/r/demo/tests/crossrealm"
)

type Struct struct {
	A int
}

func (s *Struct) Mutate() {
	s.A += 1
}

func (s *Struct) Get() int {
	return s.A
}

func (s *Struct) PrintRealms() {
	s.printRealms()
}

func (s *Struct) printRealms(cur realm) {
	// XXX
	// printRealm is called from s.PrintRealm()
	// which in this test is persisted in the same realm.
	// Therefore p.printRealm() -> s.PrintRealm()
	// borrows this realm, and then the crossing()
	// below is called.
	// Should this be allowed?
	// Whether it panics or not is determined by
	// 'fr.DidCrossing = true' in PushFrameCall.
	fmt.Println(std.CurrentRealm())
	fmt.Println(std.PreviousRealm())
}

type Passthrough struct {
	S *Struct
}

func (p *Passthrough) Mutate() {
	p.S.Mutate()
}

func (p *Passthrough) Get() int {
	return p.S.Get()
}

func (p *Passthrough) PrintRealms() {
	p.printRealm()
}

func (p *Passthrough) printRealm() {
	p.S.PrintRealms()
}

var s *Struct

func init() {
	s = &Struct{A: 100} // saved in borrow_test.
}

func main(cur realm) {
	// cross(crossrealm_b.SetObject)(s) // saved in crossrealm_b

	p := &Passthrough{S: s}

	crossrealm.SetObject(cross, p) // saved in crossrealm.

	p.Mutate() // receiver method borrows crossrealm_b.

	println(p.Get())

	p.PrintRealms()
}

// Error:
// gno.land/r/borrow_test/zrealm_borrow0.gno:24:2-17: missing realm argument in calling crossing function call s<VPBlock(1,0)>.printRealms() (expected cur or cross)

// TypeCheckError:
// gno.land/r/borrow_test/zrealm_borrow0.gno:24:16: not enough arguments in call to s.printRealms
// 	have ()
// 	want (realm)
