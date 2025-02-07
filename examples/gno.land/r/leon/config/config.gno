package config

import (
	"errors"
	"std"
	"strconv"
	"strings"
	"time"

	"gno.land/p/demo/avl"
	p "gno.land/p/demo/avl/pager"
	"gno.land/p/demo/ownable"
	"gno.land/p/demo/ufmt"
	"gno.land/p/moul/md"
	"gno.land/p/moul/realmpath"
	"gno.land/p/moul/txlink"
)

var (
	configs = avl.NewTree()
	pager   = p.NewPager(configs, 10, false)
	banner  = "---\n[[Leon's Home page]](/r/leon/home) | [[Leon's configs]](/r/leon/config) | [[GitHub: @leohhhn]](https://github.com/leohhhn)\n\n---"
	absPath = strings.TrimPrefix(std.CurrentRealm().PkgPath(), std.GetChainDomain())

	// SafeObjects
	OwnableMain   = ownable.NewWithAddress("g125em6arxsnj49vx35f0n0z34putv5ty3376fg5") // can be re-exposed
	OwnableBackup = ownable.NewWithAddress("g1lavlav7zwsjqlzzl3qdl3nl242qtf638vnhdjh")

	ErrUnauthorized = errors.New("leon's config: unauthorized")
)

type Config struct {
	name    string
	lines   string
	updated time.Time
}

func AddConfig(name, lines string) {
	if !IsAuthorized(std.PrevRealm().Addr()) {
		panic(ErrUnauthorized)
	}

	configs.Set(strings.TrimSpace(name), &Config{
		name:    name,
		lines:   lines,
		updated: time.Now(),
	}) // no overwrite check
}

func EditConfig(name, lines string) {
	if !IsAuthorized(std.PrevRealm().Addr()) {
		panic(ErrUnauthorized)
	}

	raw, ok := configs.Get(strings.TrimSpace(name))
	if !ok {
		panic("couldn't find requested config")
	}

	c := raw.(*Config)
	c.lines = lines
	c.updated = time.Now()
}

func RemoveConfig(name string) {
	if !IsAuthorized(std.PrevRealm().Addr()) {
		panic(ErrUnauthorized)
	}

	if _, ok := configs.Remove(name); !ok {
		panic("no config with that name")
	}
}

func UpdateBanner(newBanner string) {
	if !IsAuthorized(std.PrevRealm().Addr()) {
		panic(ErrUnauthorized)
	}

	banner = newBanner
}

func IsAuthorized(addr std.Address) bool {
	return addr == OwnableMain.Owner() || addr == OwnableBackup.Owner()
}

func Banner() string {
	return banner
}

func Render(path string) (out string) {
	req := realmpath.Parse(path)

	switch req.Path {
	case "":
		return renderHome(req.Path, false)
	case "admin":
		return renderHome(req.Path, true)
	default:
		return renderConfPage(req.Path)
	}
}

func renderHome(path string, admin bool) string {
	out := md.H1("Leon's config package")

	out += ufmt.Sprintf("Leon's main address: %s\n\n", OwnableMain.Owner().String())
	out += ufmt.Sprintf("Leon's backup address: %s\n\n", OwnableBackup.Owner().String())

	out += md.H2("Leon's configs")

	if configs.Size() == 0 {
		out += "No configs yet :c\n\n"
	}

	page := pager.MustGetPageByPath(path)
	for _, item := range page.Items {
		if admin {
			out += ufmt.Sprintf("- [%s](%s:%s) - [Edit](%s) - [Delete](%s)\n\n", item.Key, absPath, item.Key,
				txlink.Call("EditConfig", "name", item.Key),
				txlink.Call("RemoveConfig", "name", item.Key),
			)
		} else {
			out += ufmt.Sprintf("- [%s](%s:%s)\n\n", item.Key, absPath, item.Key)
		}
	}

	if page.TotalPages > 0 {
		out += page.Picker()
		out += "\n\n"
		out += "Page " + strconv.Itoa(page.PageNumber) + " of " + strconv.Itoa(page.TotalPages) + "\n\n"
	}

	out += Banner()

	return out
}

func renderConfPage(confName string) (out string) {
	raw, ok := configs.Get(confName)
	if !ok {
		out += md.H1("404")
		out += "That config does not exist :/"
		return out
	}

	conf := raw.(*Config)
	out += md.H1(confName)
	out += ufmt.Sprintf("_Last updated on %s_\n\n", conf.updated.Format("02 Jan, 2006"))
	out += ufmt.Sprintf("```\n%s\n```\n\n", conf.lines)

	return out
}
