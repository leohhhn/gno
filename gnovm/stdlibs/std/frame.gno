package std

type Realm struct {
	addr    Address
	pkgPath string
}

// Address returns the address of the realm
func (r Realm) Address() Address {
	return r.addr
}

// PkgPath returns the pkgpath of the realm
func (r Realm) PkgPath() string {
	return r.pkgPath
}

// IsUser checks if the realm is a user realm.
// Returns true if the realm is an EOA, or is a MsgRun message.
func (r Realm) IsUser() bool {
	return r.pkgPath == ""
}

// CoinDenom
func (r Realm) CoinDenom(coinName string) string {
	return CoinDenom(r.pkgPath, coinName)
}

func CoinDenom(pkgPath, coinName string) string {
	// TODO: Possibly remove after https://github.com/gnolang/gno/issues/3164
	// Similar to ibc spec
	// ibc_denom := 'ibc/' + hash('path' + 'base_denom')
	// gno_qualified_denom := '/' + 'pkg_path' + ':' + 'base_denom'
	return "/" + pkgPath + ":" + coinName
}
