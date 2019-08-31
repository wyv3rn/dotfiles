package main

import (
	"bufio"
	"errors"
	"flag"
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
	alias    string
	fullName string
	mail     string
}

func (a *Alias) ToMuttFormat() string {
	return fmt.Sprintf("alias %s %s <%s>", a.alias, a.fullName, a.mail)
}

func (a Alias) String() string {
	return a.ToMuttFormat()
}

func AliasFromMuttFormat(muttString string) (Alias, error) {
	r := regexp.MustCompile(`alias (?P<alias>\S+) (?P<name>[^>]+) <(?P<mail>\S+)>`)
	match := r.FindStringSubmatch(muttString)
	if match == nil {
		return Alias{}, errors.New("Wrong format")
	}
	return Alias{match[1], match[2], match[3]}, nil
}

func AliasListFromScanner(scanner *bufio.Scanner) []Alias {
	aliases := make([]Alias, 0)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if len(line) == 0 {
			continue
		}
		alias, err := AliasFromMuttFormat(line)
		if err != nil {
			fmt.Printf("[WARN] Skipping (and deleting) entry because the format is not correct: %s\n", line)
			continue
		}
		aliases = append(aliases, alias)
	}
	return aliases
}

func ResolveConflict(a, b *Alias) *Alias {
	assert(false, fmt.Sprintf("Conflict detected, handling not implemented yet\n%s\n%s\n", *a, *b))
	return a // TODO implement for real
}

func main() {
	// parse arguments
	var deleteAlias, localFilename, remoteHost, username, remoteFilename string
	flag.StringVar(&deleteAlias, "delete", "", "Delete alias while syncing")
	flag.StringVar(&remoteHost, "host", "alpha", "Remote host (default: alpha)")
	flag.StringVar(&username, "user", "", "Remote user name (default: your local username")
	flag.StringVar(&localFilename, "local-filename", "~/.neomutt/aliases.rc", "Local alias file (default: ~/.neomutt/aliases.rc")
	flag.StringVar(&remoteFilename, "remote-filename", ".neomutt/aliases.rc", "Remote alias file, relative to remote users home; must exist! (default: .neomutt/aliases.rc)")
	flag.Parse()

	localFilename, err := expanduser(localFilename)
	assert(err == nil, "Expanding home directory in local filename failed")

	var remote string
	if username != "" {
		remote = fmt.Sprintf("%s@%s", username, remoteHost)
	} else {
		remote = remoteHost
	}

	cmd := exec.Command("ssh", remote, "cat", remoteFilename)
	cmdReader, err := cmd.StdoutPipe()
	assert(err == nil, "Failed getting stdout pipe")

	scanner := bufio.NewScanner(cmdReader)
	var remoteList []Alias
	// fetch remote list in go-routine
	go func() {
		remoteList = AliasListFromScanner(scanner)
	}()

	err = cmd.Start()
	assert(err == nil, "Starting ssh command failed")

	localFileExists := true
	localFile, err := os.Open(localFilename)
	if os.IsNotExist(err) {
		localFileExists = false
	} else {
		assert(err == nil, fmt.Sprintf("Opening local file failed: %v", err))
	}
	defer localFile.Close()
	scanner = bufio.NewScanner(localFile)
	localList := AliasListFromScanner(scanner)
	sort.Slice(localList, func(i, j int) bool {
		return localList[i].alias < localList[j].alias
	})

	// wait for the remote fetching
	err = cmd.Wait()
	assert(err == nil, fmt.Sprintf("Waiting for the ssh command failed: %v", err))

	/// TODO avoid copy and paste of custom comparison?
	sort.Slice(remoteList, func(i, j int) bool {
		return remoteList[i].alias < remoteList[j].alias
	})

	// merge together
	merged := make([]Alias, 0, len(remoteList)+len(localList))
	i, j := 0, 0
	for i < len(remoteList) || j < len(localList) {
		var nextPtr *Alias
		if i >= len(remoteList) {
			nextPtr = &localList[j]
			j++
		} else if j >= len(localList) {
			nextPtr = &remoteList[i]
			i++
		} else {
			remotePtr := &remoteList[i]
			localPtr := &localList[j]
			if remotePtr.alias < localPtr.alias {
				nextPtr = remotePtr
				i++
			} else if remotePtr.alias > localPtr.alias {
				nextPtr = localPtr
				j++
			} else {
				// same alias, check if its a conflict or if its a duplicate
				if *remotePtr == *localPtr {
					// duplicate -> take one, skip the other
					nextPtr = localPtr
					i++
					j++
				} else { // conflict
					nextPtr = ResolveConflict(remotePtr, localPtr)
				}
			}
		}

		assert(nextPtr != nil, "No next entry to take?")
		if nextPtr.alias != deleteAlias {
			// check for duplicate with the last entry as well
			if len(merged) > 0 {
				lastPtr := &merged[len(merged)-1]
				if nextPtr.alias == lastPtr.alias {
					nextPtr = nil             // don't add another element, either skip or overwrite last
					if *nextPtr == *lastPtr { // skip duplicate
					} else { // conflict -> override last entry with resolved version
						*lastPtr = *ResolveConflict(nextPtr, lastPtr)
					}
				}
			}
			if nextPtr != nil {
				merged = append(merged, *nextPtr)
			}
		}
	}

	// overwrite local with merged version (but backup old one first)
	if localFileExists {
		backupFilename := fmt.Sprintf("%s.bak", localFilename)
		err = os.Rename(localFilename, backupFilename)
		assert(err == nil, "Backing up local file failed")
	}

	newLocalFile, err := os.Create(localFilename)
	assert(err == nil, "Creating new local file failed")
	defer newLocalFile.Close()

	for _, a := range merged {
		newLocalFile.WriteString(fmt.Sprintf("%s\n", a.ToMuttFormat()))
		fmt.Printf(fmt.Sprintf("%s\n", a.ToMuttFormat()))
	}

	// overwrite remote with merged version
	err = exec.Command("scp", localFilename, fmt.Sprintf("%s:%s", remote, remoteFilename)).Run()
	assert(err == nil, "Syncing merged version to remote failed")
}
