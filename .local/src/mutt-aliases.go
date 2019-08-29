package main

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

func expanduser(path string) (string, error) {
	if len(path) == 0 || path[0] != '~' {
		return path, nil
	}

	usr, err := user.Current()
	if err != nil {
		return "", err
	}

	return filepath.Join(usr.HomeDir, path[1:]), nil
}

func assert(b bool, msg string) {
	if b != true {
		fmt.Printf("Assertion failed: %s\n", msg)
		os.Exit(1)
	}
}

type Alias struct {
	alias     string
	full_name string
	mail      string
}

func (a *Alias) to_mutt_format() string {
	return fmt.Sprintf("alias %s %s <%s>", a.alias, a.full_name, a.mail)
}

func (a Alias) String() string {
	return a.to_mutt_format()
}

func alias_from_mutt_format(mutt_string string) (Alias, error) {
	r := regexp.MustCompile(`alias (?P<alias>\S+) (?P<name>[^>]+) <(?P<mail>\S+)>`)
	match := r.FindStringSubmatch(mutt_string)
	if match == nil {
		return Alias{}, errors.New("Wrong format")
	} else {
		return Alias{match[1], match[2], match[3]}, nil
	}
}

func alias_list_from_scanner(scanner *bufio.Scanner) []Alias {
	aliases := make([]Alias, 0)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if len(line) == 0 {
			continue
		}
		alias, err := alias_from_mutt_format(line)
		if err != nil {
			fmt.Printf("[WARN] Skipping (and deleting) entry because the format is not correct: %s\n", line)
			continue
		}
		aliases = append(aliases, alias)
	}
	return aliases
}

func main() {
	local_filename, err := expanduser("~/.neomutt/aliases.rc")
	assert(err == nil, "Expanding home directory in local filename failed")

	remote_filename := ".neomutt/aliases.rc"
	remote_host := "alpha"
	cmd := exec.Command("ssh", remote_host, "cat", remote_filename)
	cmdReader, err := cmd.StdoutPipe()
	assert(err == nil, "Failed getting stdout pipe")

	scanner := bufio.NewScanner(cmdReader)
	var remote_list []Alias
	// fetch remote list in go-routine
	go func() {
		remote_list = alias_list_from_scanner(scanner)
	}()

	err = cmd.Start()
	assert(err == nil, "Starting ssh command failed")

	local_file, err := os.Open(local_filename)
	assert(err == nil, "Opening local file failed")
	defer local_file.Close()
	scanner = bufio.NewScanner(local_file)
	local_list := alias_list_from_scanner(scanner)
	sort.Slice(local_list, func(i, j int) bool {
		return local_list[i].alias < local_list[j].alias
	})

	// wait for the remote fetching
	err = cmd.Wait()
	assert(err == nil, "Waiting for the ssh command failed")

	/// TODO avoid copy and paste of custom comparison?
	sort.Slice(remote_list, func(i, j int) bool {
		return remote_list[i].alias < remote_list[j].alias
	})

	// merge together
	merged := make([]Alias, 0, len(remote_list)+len(local_list))
	i, j := 0, 0
	for i < len(remote_list) && j < len(local_list) {
		remote := &remote_list[i]
		local := &local_list[j]
		if remote.alias < local.alias {
			merged = append(merged, *remote)
			i++
		} else if remote.alias > local.alias {
			merged = append(merged, *local)
			j++
		} else {
			// same alias, check if its a conflict or if its a duplicate
			if *remote == *local {
				// duplicate -> take one, skip the other
				merged = append(merged, *remote)
				i++
				j++
			} else {
				// conflict
				assert(false, fmt.Sprintf("Conflict detected, handling not implemented yet\n%s\n%s\n", *remote, *local))
			}
		}
	}
	for i < len(remote_list) {
		merged = append(merged, remote_list[i])
		i++
	}
	for j < len(local_list) {
		merged = append(merged, local_list[j])
		j++
	}

	// overwrite local with merged version (but backup old one first)
	backup_filename := fmt.Sprintf("%s.bak", local_filename)
	err = os.Rename(local_filename, backup_filename)
	assert(err == nil, "Backing up local file failed")

	new_local_file, err := os.Create(local_filename)
	assert(err == nil, "Creating new local file failed")
	defer new_local_file.Close()

	for _, a := range merged {
		new_local_file.WriteString(fmt.Sprintf("%s\n", a.to_mutt_format()))
	}

	// overwrite remote with merged version
	err = exec.Command("scp", local_filename, fmt.Sprintf("%s:%s", remote_host, remote_filename)).Run()
	assert(err == nil, "Syncing merged version to remote failed")
}
