package main

import (
	"fmt"
	"flag"
	"log"
	"bufio"
	"time"
	"strings"
	"context"
	"os/exec"
)

type Results struct {
	Host string
	Payload string
}

func main() {
	var seconds int
	flag.IntVar(&seconds, "s", 180, "set how long to wait before timing out on a specific host (in seconds)")

	var debug bool
	flag.BoolVar(&debug, "d", false, "show the actual output of smuggler.py")

	var url string
	flag.StringVar(&url, "u", "REQUIRED", "the target url to scan")
	flag.Parse()

	r, err := smuggler(url, seconds, debug)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Scanned host: %s, potential payload: %s\n", r.Host, r.Payload)
}

// line by line execution
func smuggler(u string, sec int, debug bool) (Results, error) {
	var r Results
	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(sec) * time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "./resources/smuggler/smuggler.py", "-x", "-u", u)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Fatalln(err)
	}
	cmd.Start()

	s := bufio.NewScanner(stdout)
	for s.Scan() {
		l := s.Text()
		if debug {
			// show the output
			fmt.Println(l)
		}
		if strings.Contains(l, "CRITICAL") {
			f := strings.Fields(l)
			r.Payload = f[5]
//			r = Results{f[7], f[5]}
			// the struct is completely uneccessary for the moment. It's for later when we start storing in a db
//			fmt.Printf("Scanned host: %s, potential payload: %s\n", r.Host, r.Payload)
		}
		r.Host = u
	}
	cmd.Wait()
	return r, err
}
