package events

import "std"

var usernames map[std.Address]string

func RegisterUserName(username string) {
	caller := std.PrevRealm().Addr()

	if usernames[caller] != "" {
		panic("you have already registered a username")
	}
	if username == "" {
		panic("username cannot be empty")
	}

	usernames[caller] = username
	std.Emit("Registration", "registrant", caller.String(), "username", username)
}
