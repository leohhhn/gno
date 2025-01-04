package userreg

import (
	"std"
	"strings"

	"gno.land/p/demo/avl"
)

type UserData struct {
	addr     std.Address
	username string
	alias    *UserData
	deleted  bool
}

func (u UserData) IsDeleted() bool {
	// No need to resolve, any UserData this is called upon will already be resolved
	return u.deleted
}

var (
	nameStore    = avl.NewTree()
	addressStore = avl.NewTree()
)

// todo add regex addr lookalike check
const maxNameLength = 64

// Register adds a new user to the system.
func Register(name string, address std.Address) error {
	// Validate inputs
	if err := validateName(name); err != nil {
		return err
	}

	if !address.IsValid() {
		return ErrInvalidAddress
	}

	// Check if name is taken
	if nameStore.Has(name) {
		return ErrNameTaken
	}

	raw, ok := addressStore.Get(address.String())
	if ok {
		// Cannot re-register after deletion
		if raw.(*UserData).IsDeleted() {
			return ErrDeletedUser
		}

		// For a second name, user RegisterAlias
		return ErrAlreadyHasName
	}

	// Create UserData
	data := &UserData{
		addr:     address,
		username: name,
		alias:    nil,
		deleted:  false,
	}

	// Set corresponding stores
	nameStore.Set(name, data)
	addressStore.Set(address.String(), data)

	return nil
}

// RegisterAlias adds an alias pointing to an existing user.
func RegisterAlias(alias string, address std.Address) error {
	// Validate inputs
	if err := validateName(alias); err != nil {
		return err
	}

	if !address.IsValid() {
		return ErrInvalidAddress
	}

	// Check if requested alias is already taken
	if nameStore.Has(alias) {
		return ErrNameTaken
	}

	// Check if user has a name before an alias
	raw, ok := addressStore.Get(address.String())
	if !ok {
		return ErrAliasBeforeName
	}

	if raw.(*UserData).IsDeleted() {
		return ErrDeletedUser
	}

	// Create new Alias
	newData := &UserData{
		addr:     address,
		username: alias,
		alias:    nil,
		deleted:  false,
	}

	oldData := raw.(*UserData)
	// Point to new alias
	oldData.alias = newData
	oldData.addr = ""

	// Set latest alias to stores
	addressStore.Set(address.String(), newData)
	nameStore.Set(alias, newData)

	return nil
}

// Delete marks a user and all their aliases as deleted.
func Delete(name string) error {
	data := ResolveName(name)
	if data == nil {
		return ErrUserNotExist
	}

	if data.deleted {
		return ErrAlreadyDeleted
	}

	data.deleted = true
	// data.addr = "" // I don't think we should do this, might cause problems later
	data.username = "ghost"

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

func validateName(name string) error {
	trimmed := strings.TrimSpace(name)
	if trimmed == "" || len(trimmed) > maxNameLength {
		return ErrInvalidName
	}

	return nil
}
