package main

import (
	"fmt"
	"net/http"
	"os"
	"net"
)

func eight_ball(w http.ResponseWriter, req *http.Request) {
	commit := os.Getenv("VERSION")
	if commit == "" {
		commit = "HEAD"
	}

	addrs, _ := net.InterfaceAddrs()
	fmt.Fprintf(w, "From %s on %s\n", commit, addrs[1])
	fmt.Fprintf(w, "The magic 8 ball says: ")
}

func main() {
	http.HandleFunc("/", eight_ball)

	http.ListenAndServe(":8080", nil)
}
