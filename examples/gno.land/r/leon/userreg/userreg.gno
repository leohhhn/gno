package userreg

import (
	"std"

	"gno.land/p/demo/avl"
)

type UserData struct {
	addr     std.Address
	username string
	alias    *UserData
	deleted  bool
}

func (u UserData) IsDeleted() bool {
	return ResolveName(u.username).deleted
}

var (
	nameStore    = avl.NewTree()
	addressStore = avl.NewTree()
)

// Register adds a new user to the system.
func Register(name string, address std.Address) error {
	if nameStore.Has(name) {
		panic("name taken")
	}

	raw, ok := addressStore.Get(address.String())
	if ok {
		if raw.(*UserData).IsDeleted() {
			panic("cannot reregister after deletion")
		}

		panic("use RegisterAlias")
	}

	data := &UserData{
		addr:     address,
		username: name,
		alias:    nil,
		deleted:  false,
	}

	nameStore.Set(name, data)
	addressStore.Set(address.String(), data)

	return nil
}

// RegisterAlias adds an alias pointing to an existing user.
func RegisterAlias(alias string, address std.Address) error {
	if nameStore.Has(alias) {
		panic("name taken")
	}

	raw, ok := addressStore.Get(address.String())
	if !ok {
		panic("address not registered")
	}

	oldData := raw.(*UserData)

	newData := &UserData{
		addr:     address,
		username: alias,
		alias:    nil,
		deleted:  false,
	}

	oldData.alias = newData
	oldData.addr = ""

	addressStore.Set(address.String(), newData)
	nameStore.Set(alias, newData)

	return nil
}

// ResolveName finds the original NameRecord for a given name or alias.
func ResolveName(name string) *UserData {
	raw, ok := nameStore.Get(name)
	if !ok {
		return nil
	}

	data := raw.(*UserData)
	for data.alias != nil {
		data = data.alias
	}
	return data
}

func ResolveAddress(addr std.Address) *UserData {
	raw, ok := addressStore.Get(addr.String())
	if !ok {
		return nil
	}

	data := raw.(*UserData)
	if data.deleted {
		return nil
	}

	for data.alias != nil {
		data = data.alias
	}
	return data
}

// Delete marks a user and all their aliases as deleted.
func Delete(name string) error {
	data := ResolveName(name)
	if data == nil {
		panic("non-existent user")
	}

	data.deleted = true
	data.username = "ghost"

	return nil
}

// USER SIDE Usage example:
//
/// 	res := ResolveName("alice")
//		if res == nil {
//			// alice does not exist
//		}
//
//		if res.IsDeleted() {
//			// alice chose to be a ghost
//		}
//
//		// possible user mistakes
//		if res != nil {
//			token.Transfer(res.address, 10000) // will fail if user has been deleted
//		}
//
//		^^^	in this case maybe Resolve() should be Resolve() *UserData, deleted
// 							mainly to make the UX stand out to the user that they might be deleted,
// 							and what that could mean.
// 							another solution is to not delete the address from the deleted user, but only the name
