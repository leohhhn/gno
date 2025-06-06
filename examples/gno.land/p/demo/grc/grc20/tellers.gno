package grc20

import (
	"std"
)

// CallerTeller returns a GRC20 compatible teller that checks the PreviousRealm
// caller for each call. It's usually safe to expose it publicly to let users
// manipulate their tokens directly, or for realms to use their allowance.
func (tok *Token) CallerTeller() Teller {
	if tok == nil {
		panic("Token cannot be nil")
	}

	return &fnTeller{
		accountFn: func() std.Address {
			caller := std.PreviousRealm().Address()
			return caller
		},
		Token: tok,
	}
}

// ReadonlyTeller is a GRC20 compatible teller that panics for any write operation.
func (tok *Token) ReadonlyTeller() Teller {
	if tok == nil {
		panic("Token cannot be nil")
	}

	return &fnTeller{
		accountFn: nil,
		Token:     tok,
	}
}

// RealmTeller returns a GRC20 compatible teller that will store the
// caller realm permanently. Calling anything through this teller will
// result in allowance or balance changes for the realm that initialized the teller.
// The initializer of this teller should usually never share the resulting Teller from
// this method except maybe for advanced delegation flows such as a DAO treasury
// management.
func (tok *Token) RealmTeller() Teller {
	if tok == nil {
		panic("Token cannot be nil")
	}

	caller := std.CurrentRealm().Address()

	return &fnTeller{
		accountFn: func() std.Address {
			return caller
		},
		Token: tok,
	}
}

// RealmSubTeller is like RealmTeller but uses the provided slug to derive a
// subaccount.
func (tok *Token) RealmSubTeller(slug string) Teller {
	if tok == nil {
		panic("Token cannot be nil")
	}

	caller := std.CurrentRealm().Address()
	account := accountSlugAddr(caller, slug)

	return &fnTeller{
		accountFn: func() std.Address {
			return account
		},
		Token: tok,
	}
}

// ImpersonateTeller returns a GRC20 compatible teller that impersonates as a
// specified address. This allows operations to be performed as if they were
// executed by the given address, enabling the caller to manipulate tokens on
// behalf of that address.
//
// It is particularly useful in scenarios where a contract needs to perform
// actions on behalf of a user or another account, without exposing the
// underlying logic or requiring direct access to the user's account. The
// returned teller will use the provided address for all operations, effectively
// masking the original caller.
//
// This method should be used with caution, as it allows for potentially
// sensitive operations to be performed under the guise of another address.
func (ledger *PrivateLedger) ImpersonateTeller(addr std.Address) Teller {
	if ledger == nil {
		panic("Ledger cannot be nil")
	}

	return &fnTeller{
		accountFn: func() std.Address {
			return addr
		},
		Token: ledger.token,
	}
}

// generic tellers methods.
//

func (ft *fnTeller) Transfer(to std.Address, amount int64) error {
	if ft.accountFn == nil {
		return ErrReadonly
	}
	caller := ft.accountFn()
	return ft.Token.ledger.Transfer(caller, to, amount)
}

func (ft *fnTeller) Approve(spender std.Address, amount int64) error {
	if ft.accountFn == nil {
		return ErrReadonly
	}
	caller := ft.accountFn()
	return ft.Token.ledger.Approve(caller, spender, amount)
}

func (ft *fnTeller) TransferFrom(owner, to std.Address, amount int64) error {
	if ft.accountFn == nil {
		return ErrReadonly
	}
	spender := ft.accountFn()
	return ft.Token.ledger.TransferFrom(owner, spender, to, amount)
}

// helpers
//

// accountSlugAddr returns the address derived from the specified address and slug.
func accountSlugAddr(addr std.Address, slug string) std.Address {
	// XXX: use a new `std.XXX` call for this.
	if slug == "" {
		return addr
	}
	key := addr.String() + "/" + slug
	return std.DerivePkgAddr(key) // temporarily using this helper
}
