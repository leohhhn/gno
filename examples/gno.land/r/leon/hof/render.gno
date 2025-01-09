package hof

import (
	"strings"

	"gno.land/p/demo/avl/pager"
	"gno.land/p/demo/fqname"
	"gno.land/p/demo/seqid"
	"gno.land/p/demo/ufmt"
	"gno.land/p/moul/md"
	"gno.land/p/moul/txlink"
)

const (
	pageSize = 5
)

func Render(path string) string {
	out := "# Hall of Fame\n\n"

	dashboardEnabled := path == "dashboard"

	if !dashboardEnabled {
		out += hofDescription
	} else {
		out += renderDashboard()
	}

	out += md.H2("Submissions")

	out += exhibition.Render(path, dashboardEnabled)

	return out
}

func (e Exhibition) Render(path string, dashboard bool) string {
	out := ufmt.Sprintf("%s\n\n", e.description)

	if e.items.Size() == 0 {
		out += "No items in this exhibition currently.\n\n"
		return out
	}

	out += "<div class='columns-2'>\n\n"

	page := pager.NewPager(e.itemsSorted, pageSize, false).MustGetPageByPath(path)

	for i := len(page.Items) - 1; i >= 0; i-- {
		item := page.Items[i]

		submission := item.Value.(*Item)
		out += "<div>\n\n"
		id, _ := seqid.FromString(item.Key)
		out += ufmt.Sprintf("**Submission #%d - %s**\n\n", int(id), submission.title)
		out += submission.Render(dashboard)
		out += "---\n\n"
		out += "</div>"
	}

	out += "</div><!-- /columns-2 -->\n\n"

	out += page.Picker()

	return out
}

func (i Item) Render(dashboard bool) string {
	out := ufmt.Sprintf("\n`%s`\n\n", i.pkgpath)
	out += ufmt.Sprintf("by %s\n\n", strings.Split(i.pkgpath, "/")[2])
	out += ufmt.Sprintf("[View realm](%s)\n\n", strings.TrimPrefix(i.pkgpath, "gno.land")) // gno.land/r/leon/home > /r/leon/home
	out += ufmt.Sprintf("Submitted at Block #%d\n\n", i.blockNum)

	out += ufmt.Sprintf("**[%d👍](%s) - [%d👎](%s)**\n\n",
		i.upvote.Size(), txlink.Call("Upvote", "pkgpath", i.pkgpath),
		i.downvote.Size(), txlink.Call("Downvote", "pkgpath", i.pkgpath),
	)

	if dashboard {
		out += ufmt.Sprintf("[Delete](%s)", txlink.Call("Delete", "pkgpath", i.pkgpath))
	}

	out += "\n\n"

	return out
}

func renderDashboard() string {
	out := "---\n\n"
	out += "## Dashboard\n\n"
	out += ufmt.Sprintf("Total submissions: %d\n\n", exhibition.items.Size())

	out += ufmt.Sprintf("Exhibition admin: %s\n\n", Ownable.Owner().String())

	if !Pausable.IsPaused() {
		out += ufmt.Sprintf("[Pause exhibition](%s)\n\n", txlink.Call("Pause"))
	} else {
		out += ufmt.Sprintf("[Unpause exhibition](%s)\n\n", txlink.Call("Unpause"))
	}

	out += "---\n\n"

	return out
}

func RenderExhibWidget(itemsToRender int) string {
	if itemsToRender < 1 {
		return ""
	}

	out := ""
	i := 0
	exhibition.items.Iterate("", "", func(key string, value interface{}) bool {
		item := value.(*Item)

		out += ufmt.Sprintf("- %s\n", fqname.RenderLink(item.pkgpath, ""))

		i++
		return i >= itemsToRender
	})

	return out
}

var (
	hofDescription = ` ## Overview
Welcome to the Hall of Fame!
Here, users can permissionlessly display their projects that they want to share with the community.
To add your realm to the Hall of Fame, simply import it, and call Register(), giving it a brief description
of what your realm is. For example, check out the code below: 
` + "```go\n" + exampleCode + "\n```\n\n" + md.Bold("Happy coding!") + "\n\n"

	exampleCode = `package mycoolrealm

import "gno.land/r/leon/hof"

func init() {
	hof.Register("Leon's super cool realm", "My realm is super cool!")
}

func MyCoolFunction() {
	...
}`
)
