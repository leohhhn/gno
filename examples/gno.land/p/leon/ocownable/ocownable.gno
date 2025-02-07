// Package ocownable is p/demo/ownable, but uses the OrigCall for authorization
// This allows a user to define a single config realm exposing the OrigCallerOwnable
// object, which could be re-exposed multiple times instead of making a new ownable object
// every time a user needs admin access features.
// WARN: Please make sure that you understand what this package does before using it.
// The writers of this package are not responsible for any possible issues or bugs.
package ocownable

import (
	"errors"
	"std"
)

const OwnershipTransferEvent = "OwnershipTransfer"

var (
	ErrUnauthorized   = errors.New("ownable: caller is not owner")
	ErrInvalidAddress = errors.New("ownable: new owner address is invalid")
)

type OCOwnable struct {
	origCaller std.Address
}

func New() *OCOwnable {
	return &OCOwnable{origCaller: std.GetOrigCaller()}
}

func NewWithAddress(addr std.Address) *OCOwnable {
	if !addr.IsValid() {
		panic(ErrInvalidAddress)
	}
	return &OCOwnable{origCaller: addr}
}

// TransferOwnership transfers ownership of the Ownable struct to a new address
func (o *OCOwnable) TransferOwnership(newOwner std.Address) error {
	if !o.CallerIsOwner() {
		return ErrUnauthorized
	}

	if !newOwner.IsValid() {
		return ErrInvalidAddress
	}

	prevOwner := o.origCaller
	o.origCaller = newOwner
	std.Emit(
		OwnershipTransferEvent,
		"from", prevOwner.String(),
		"to", newOwner.String(),
	)

	return nil
}

// DropOwnership removes the owner, effectively disabling any owner-related actions
// Top-level usage: disables all only-owner actions/functions,
// Embedded usage: behaves like a burn functionality, removing the owner from the struct
func (o *OCOwnable) DropOwnership() error {
	if !o.CallerIsOwner() {
		return ErrUnauthorized
	}

	prevOwner := o.origCaller
	o.origCaller = ""

	std.Emit(
		OwnershipTransferEvent,
		"from", prevOwner.String(),
		"to", "",
	)

	return nil
}

// Owner returns the owner address from Ownable
func (o *OCOwnable) Owner() std.Address {
	if o == nil {
		return std.Address("")
	}
	return o.origCaller
}

// CallerIsOwner checks if the caller of the function is the Realm's owner
func (o *OCOwnable) CallerIsOwner() bool {
	if o == nil {
		return false
	}
	return std.GetOrigCaller() == o.origCaller
}

// AssertCallerIsOwner panics if the caller is not the owner
func (o *OCOwnable) AssertCallerIsOwner() {
	if o == nil {
		panic(ErrUnauthorized)
	}
	caller := std.GetOrigCaller()
	if caller != o.origCaller {
		panic(ErrUnauthorized)
	}
}
