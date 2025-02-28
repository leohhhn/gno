// Package fm provides a simple helper to add frontmatter to your realm renders
package fm

func Write(title, description string) string {
	out := "---" + "\n"
	out += "Title: " + title + "\n"
	out += "Description: " + description + "\n"
	out += "---" + "\n"

	return out
}
