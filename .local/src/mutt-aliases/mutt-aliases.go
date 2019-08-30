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

func aliasFromMuttFormat(muttString string) (Alias, error) {
	r := regexp.MustCompile(`alias (?P<alias>\S+) (?P<name>[^>]+) <(?P<mail>\S+)>`)
	match := r.FindStringSubmatch(muttString)
	if match == nil {
		return Alias{}, errors.New("Wrong format")
	} else {
		return Alias{match[1], match[2], match[3]}, nil
	}
}

func aliasListFromScanner(scanner *bufio.Scanner) []Alias {
	aliases := make([]Alias, 0)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if len(line) == 0 {
			continue
		}
		alias, err := aliasFromMuttFormat(line)
		if err != nil {
			fmt.Printf("[WARN] Skipping (and deleting) entry because the format is not correct: %s\n", line)
			continue
		}
		aliases = append(aliases, alias)
	}
	return aliases
}

func main() {
	// parse arguments
	var deleteAlias, localFilename string
	flag.StringVar(&deleteAlias, "delete", "", "Delete alias while syncing")
	flag.StringVar(&localFilename, "local-filename", "~/.neomutt/aliases.rc", "Local alias file")
	flag.Parse()

	localFilename, err := expanduser(localFilename)
	assert(err == nil, "Expanding home directory in local filename failed")

	remoteFilename := ".neomutt/aliases.rc"
	remoteHost := "alpha"
	cmd := exec.Command("ssh", remoteHost, "cat", remoteFilename)
	cmdReader, err := cmd.StdoutPipe()
	assert(err == nil, "Failed getting stdout pipe")

	scanner := bufio.NewScanner(cmdReader)
	var remoteList []Alias
	// fetch remote list in go-routine
	go func() {
		remoteList = aliasListFromScanner(scanner)
	}()

	err = cmd.Start()
	assert(err == nil, "Starting ssh command failed")

	localFile, err := os.Open(localFilename)
	assert(err == nil, "Opening local file failed")
	defer localFile.Close()
	scanner = bufio.NewScanner(localFile)
	localList := aliasListFromScanner(scanner)
	sort.Slice(localList, func(i, j int) bool {
		return localList[i].alias < localList[j].alias
	})

	// wait for the remote fetching
	err = cmd.Wait()
	assert(err == nil, "Waiting for the ssh command failed")

	/// TODO avoid copy and paste of custom comparison?
	sort.Slice(remoteList, func(i, j int) bool {
		return remoteList[i].alias < remoteList[j].alias
	})

	// merge together
	merged := make([]Alias, 0, len(remoteList)+len(localList))
	i, j := 0, 0
	for i < len(remoteList) && j < len(localList) {
		remotePtr := &remoteList[i]
		localPtr := &localList[j]
		var nextPtr *Alias
		if remotePtr.alias < localPtr.alias {
			nextPtr = remotePtr
			i++
		} else if remotePtr.alias > localPtr.alias {
			nextPtr = localPtr
			j++
		} else {
			// same alias, check if its a conflict or if its a duplicate
			if *remotePtr == *localPtr {
				// duplicate -> take one, skip the other (but have to check for duplicate with the last taken as well -> potentially skipping both)
				nextPtr = localPtr
				if len(merged) > 0 {
					lastPtr := &merged[len(merged)-1]
					if nextPtr.alias == lastPtr.alias {
						if *nextPtr == *lastPtr {
							// skip this duplicate as well
							nextPtr = nil
						} else {
							assert(false, fmt.Sprintf("Conflict detected, handling not implemented yet\n%s\n%s\n", *nextPtr, *lastPtr))
						}
					}
				}
				i++
				j++
			} else {
				// conflict
				assert(false, fmt.Sprintf("Conflict detected, handling not implemented yet\n%s\n%s\n", *remotePtr, *localPtr))
			}
		}

		if nextPtr != nil && nextPtr.alias != deleteAlias {
			merged = append(merged, *nextPtr)
		}
	}
	var remainingListPtr *[]Alias
	var k int

	if i < len(remoteList) {
		remainingListPtr = &remoteList
		k = i
	} else {
		remainingListPtr = &localList
		k = j
	}

	for k < len(*remainingListPtr) {
		merged = append(merged, (*remainingListPtr)[k])
		k++
	}

	// overwrite local with merged version (but backup old one first)
	backupFilename := fmt.Sprintf("%s.bak", localFilename)
	err = os.Rename(localFilename, backupFilename)
	assert(err == nil, "Backing up local file failed")

	newLocalFile, err := os.Create(localFilename)
	assert(err == nil, "Creating new local file failed")
	defer newLocalFile.Close()

	for _, a := range merged {
		newLocalFile.WriteString(fmt.Sprintf("%s\n", a.ToMuttFormat()))
		fmt.Printf(fmt.Sprintf("%s\n", a.ToMuttFormat()))
	}

	// overwrite remote with merged version
	err = exec.Command("scp", localFilename, fmt.Sprintf("%s:%s", remoteHost, remoteFilename)).Run()
	assert(err == nil, "Syncing merged version to remote failed")
}
