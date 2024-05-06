package events

import (
	"std"
)

var owner std.Address

func init() {
	owner = std.PrevRealm().Addr()
}

func ChangeOwner(newOwner std.Address) {
	caller := std.PrevRealm().Addr()

	if caller != owner {
		panic("access denied")
	}

	h := int(std.GetHeight())
	owner = newOwner

	std.Emit("OwnershipChange", "oldOwner", caller.String(), "newOwner", newOwner.String())
}

//"Events": [
//                            {
//                                "@type": "/tm.gnoEvent",
//                                "type": "OwnershipChange",
//                                "pkg_path": "gno.land/r/demo/te",
//                                "func": "ChangeOwner",
//                                "attrs": [
//                                    {
//                                        "key": "oldOwner",
//                                        "value": "g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5"
//                                    },
//                                    {
//                                        "key": "newOwner",
//                                        "value": "g1zzqd6phlfx0a809vhmykg5c6m44ap9756s7cjj"
//                                    },
//                                    {
//                                        "key": "height",
//                                        "value": "43"
//                                    }
//                                ]
//                            }
//                        ],
